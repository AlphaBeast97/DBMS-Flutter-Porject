export const DEVICE_TYPES = ["Laptop", "Mobile", "Console", "Tablet", "Other"];

export const STATUS_VALUES = ["Pending", "Repairing", "Ready", "Delivered", "Cancelled"];

// Design tokens — status color/bg/label maps, device type icons, role labels, API base URL
export const STATUS_COLORS = {
  Pending: "#B86B4B",
  Repairing: "#2D7BD1",
  Ready: "#2A9D8F",
  Delivered: "#2A9D8F",
  Cancelled: "#9A958C",
};

export const STATUS_LABELS = {
  Pending: "Pending",
  Repairing: "Repairing",
  Ready: "Ready",
  Delivered: "Delivered",
  Cancelled: "Cancelled",
};

export function statusColor(status) {
  return STATUS_COLORS[status] || "#9A958C";
}

export function statusBg(status) {
  const c = statusColor(status);
  return `color-mix(in srgb, ${c} 12%, transparent)`;
}

export function getValidTransitions(status, role) {
  if (role === "Customer") {
    if (status === "Pending" || status === "Ready") return ["Cancelled"];
    return [];
  }
  const map = {
    Pending: ["Repairing"],
    Repairing: ["Ready"],
    Ready: ["Delivered"],
  };
  return map[status] || [];
}
