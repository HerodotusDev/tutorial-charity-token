import { getSlots } from "./01-get-slots.ts";
import config from "../../config.json" assert { type: "json" };

export async function proveWithHerodotus(
  slots: ReturnType<typeof getSlots>,
  blockNumber: number
): Promise<string> {
  const herodotusQuery = {
    destinationChainId: "SN_GOERLI",
    fee: "0",
    data: {
      "5": {
        [`block:${blockNumber}`]: {
          accounts: {
            [config.charityContractAddress]: {
              slots: [slots.destAddressSlot, slots.amountSlot],
            },
          },
        },
      },
    },
  };

  console.log("\nSubmitting query to Herodotus...");
  const request = new Request(
    `https://api.herodotus.cloud/submit-batch-query?apiKey=${config.HERODOTUS_API_KEY}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(herodotusQuery),
    }
  );

  const response = await fetch(request);
  const { internalId: herodotusQueryId } = await response.json();

  console.log("Herodotus Query ID:", herodotusQueryId);
  console.log("\nThis might take even ~20 mins, sit back and relax :)");

  return herodotusQueryId;
}
