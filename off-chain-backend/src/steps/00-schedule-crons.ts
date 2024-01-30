import { Cron } from "https://deno.land/x/croner@8.0.0/dist/croner.js";
import { JsonRpcProvider, AbiCoder } from "npm:ethers@^6.10";
import { getSlots } from "./01-get-slots.ts";
import { proveWithHerodotus } from "./02-prove-with-herodotus.ts";
import { QueryStatus, checkQueryStatus } from "./03-check-query-status.ts";
import config from "../../config.json" assert { type: "json" };

export function scheduleCrons() {
  Cron("* * * * * *", { name: "listen-for-donations" }, scrapeDonations);
  Cron("* * * * * *", { name: "check-query-status" }, checkQueryStatusJob);
}

const abiCoder = AbiCoder.defaultAbiCoder();

const context: {
  lastScrapedBlockNumber: number;
  herodotusQueries: Map<string, QueryStatus>;
} = {
  lastScrapedBlockNumber: config.charityContractDeploymentBlockNumber,
  herodotusQueries: new Map(),
};

async function scrapeDonations() {
  const rpcProvider = new JsonRpcProvider(
    "https://ethereum-goerli.publicnode.com"
  );

  const toBlock = await rpcProvider.getBlockNumber();

  let events = [];
  if (context.lastScrapedBlockNumber < toBlock) {
    events = await rpcProvider.getLogs({
      fromBlock: context.lastScrapedBlockNumber,
      toBlock: toBlock,
      address: config.charityContractAddress,
      topics: [config.donationTopic],
    });

    context.lastScrapedBlockNumber = toBlock;
  }

  if (events.length === 0) return;

  for (const event of events) {
    const [benefactor, amount, starknetAddress] = abiCoder.decode(
      // Donation {
      //   address benefactor;
      //   uint256 amount;
      //   uint256 starknetAddress;
      // }
      ["address", "uint256", "uint256"],
      event.data
    ) as string[];

    const emittedAtBlockNumber = event.blockNumber;
    console.log("\nDecoded event: ", {
      benefactor,
      amount,
      starknetAddress,
    });

    const slots = getSlots(benefactor);
    console.log("Things you will need to verify proof onchain:", {
      account: benefactor,
      blockNumber: emittedAtBlockNumber,
      amountSlot: slots.amountSlot,
    });
    const herodotusQueryId = await proveWithHerodotus(
      slots,
      emittedAtBlockNumber
    );

    context.herodotusQueries.set(herodotusQueryId, "IN_PROGRESS");
  }
}

async function checkQueryStatusJob() {
  for (const queryId of context.herodotusQueries.keys()) {
    const queryStatus = await checkQueryStatus(queryId);
    const currStatus = context.herodotusQueries.get(queryId);

    if (queryStatus === currStatus) {
      continue;
    } else if (queryStatus === "DONE") {
      console.log(`\nQuery ${queryId} is DONE!`);
      context.herodotusQueries.set(queryId, "DONE");
    } else if (queryStatus === "REJECTED") {
      console.log(`\nQuery ${queryId} is REJECTED!`);
      context.herodotusQueries.set(queryId, "REJECTED");
    }
  }
}
