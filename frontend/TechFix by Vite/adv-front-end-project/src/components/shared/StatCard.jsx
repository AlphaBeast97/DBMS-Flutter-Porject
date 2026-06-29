// Stat card — icon + value + label metric display; used in ManagerPage and customer pages
import { Card, CardContent } from "@/components/ui/card";

export function StatCard({ icon: Icon, value, label }) {
  return (
    <Card>
      <CardContent className="flex items-center gap-3 p-4">
        {Icon && (
          <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-coral/10">
            <Icon className="h-5 w-5 text-coral" />
          </div>
        )}
        <div>
          <p className="text-2xl font-bold text-foreground">{value}</p>
          <p className="text-xs text-muted-foreground">{label}</p>
        </div>
      </CardContent>
    </Card>
  );
}
