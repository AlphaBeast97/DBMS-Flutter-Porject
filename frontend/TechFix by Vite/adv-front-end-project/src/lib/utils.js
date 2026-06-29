// Shared utilities — cn() class merge, fmtMoney, base64 encoding, email regex validation
import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs) {
  return twMerge(clsx(inputs));
}

export const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export const minPasswordLength = 6;

export function fmtMoney(amount) {
  const num = Number(amount) || 0;
  return "$" + num.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

export function base64(str) {
  try {
    return btoa(str);
  } catch {
    return Buffer.from(str, "utf-8").toString("base64");
  }
}
