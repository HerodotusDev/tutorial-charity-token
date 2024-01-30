import { solidityPackedKeccak256 } from "npm:ethers@^6.10";

export function getSlots(address: string): {
  destAddressSlot: string;
  amountSlot: string;
} {
  const donationsMappingSlot = 0;

  const destAddressSlot = solidityPackedKeccak256(
    ["address", "uint256"],
    [address, donationsMappingSlot]
  );

  /** We need the `slot + 1` to get the `amount` value */
  const amountSlot = "0x" + (BigInt(destAddressSlot) + 1n).toString(16);

  return { destAddressSlot, amountSlot };
}
