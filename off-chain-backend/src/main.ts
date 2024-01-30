import { scheduleCrons } from "./steps/00-schedule-crons.ts";

if (import.meta.main) {
  scheduleCrons();
}
