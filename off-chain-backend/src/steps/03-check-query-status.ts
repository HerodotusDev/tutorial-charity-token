import config from "../../config.json" assert { type: "json" };

export type QueryStatus = "IN_PROGRESS" | "DONE" | "REJECTED";

export async function checkQueryStatus(
  herodotusQueryId: string
): Promise<QueryStatus> {
  const request = new Request(
    `https://api.herodotus.cloud/batch-query-status?batchQueryId=${herodotusQueryId}&apiKey=${config.HERODOTUS_API_KEY}`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  const response = await fetch(request);
  const { queryStatus } = await response.json();

  return queryStatus;
}
