// Create device form — step 2 of 3-step wizard; type select, brand, model, serial number fields
import { useState } from "react";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Loader2 } from "lucide-react";
import { DEVICE_TYPES } from "@/lib/constants";

export function CreateDeviceForm({ api, customerId, onCreated, onBack }) {
  const [type, setType] = useState("");
  const [brand, setBrand] = useState("");
  const [model, setModel] = useState("");
  const [serialNumber, setSerialNumber] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const validate = () => {
    const e = {};
    if (!type) e.type = "Device type is required";
    if (!brand.trim()) e.brand = "Brand is required";
    if (!model.trim()) e.model = "Model is required";
    if (!serialNumber.trim()) e.serialNumber = "Serial number is required";
    return e;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const validationErrors = validate();
    setErrors(validationErrors);
    if (Object.keys(validationErrors).length > 0) {
      toast.dismiss();
      toast.error(Object.values(validationErrors)[0]);
      return;
    }

    setLoading(true);
    try {
      const result = await api.post("/api/devices", {
        customer_id: customerId,
        type,
        brand: brand.trim(),
        model: model.trim(),
        serial_number: serialNumber.trim(),
      });
      toast.dismiss();
      toast.success("Device added!");
      onCreated(result.data.data);
    } catch (err) {
      toast.dismiss();
      toast.error(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="deviceType">Device Type</Label>
        <Select value={type} onValueChange={setType}>
          <SelectTrigger id="deviceType" aria-invalid={!!errors.type}>
            <SelectValue placeholder="Select type" />
          </SelectTrigger>
          <SelectContent>
            {DEVICE_TYPES.map((t) => (
              <SelectItem key={t} value={t}>{t}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        {errors.type && <p className="text-xs text-destructive">{errors.type}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="deviceBrand">Brand</Label>
        <Input
          id="deviceBrand"
          placeholder="Apple"
          value={brand}
          onChange={(e) => setBrand(e.target.value)}
          aria-invalid={!!errors.brand}
        />
        {errors.brand && <p className="text-xs text-destructive">{errors.brand}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="deviceModel">Model</Label>
        <Input
          id="deviceModel"
          placeholder="iPhone 15"
          value={model}
          onChange={(e) => setModel(e.target.value)}
          aria-invalid={!!errors.model}
        />
        {errors.model && <p className="text-xs text-destructive">{errors.model}</p>}
      </div>
      <div className="space-y-2">
        <Label htmlFor="deviceSerial">Serial Number</Label>
        <Input
          id="deviceSerial"
          placeholder="SN12345678"
          value={serialNumber}
          onChange={(e) => setSerialNumber(e.target.value)}
          aria-invalid={!!errors.serialNumber}
        />
        {errors.serialNumber && <p className="text-xs text-destructive">{errors.serialNumber}</p>}
      </div>
      <div className="flex gap-2">
        <Button type="button" variant="outline" onClick={onBack}>
          Back
        </Button>
        <Button type="submit" disabled={loading}>
          {loading ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : null}
          Add Device & Continue
        </Button>
      </div>
    </form>
  );
}
