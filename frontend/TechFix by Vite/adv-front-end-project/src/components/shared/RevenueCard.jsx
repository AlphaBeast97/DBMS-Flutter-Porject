// Revenue card — dual-column finalized vs estimated revenue display; used in ManagerPage dashboard
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { fmtMoney } from "@/lib/utils";
import { DollarSign } from "lucide-react";

export function RevenueCard({ estimated, finalized }) {
  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="flex items-center gap-2 text-base">
          <DollarSign className="h-4 w-4 text-coral" />
          Revenue Overview
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-muted-foreground">Estimated</p>
            <p className="text-xl font-bold text-foreground">{fmtMoney(estimated)}</p>
          </div>
          <Separator orientation="vertical" className="h-10" />
          <div className="text-right">
            <p className="text-xs text-muted-foreground">Finalized</p>
            <p className="text-xl font-bold text-teal">{fmtMoney(finalized)}</p>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
