"use client";

import { AlertCircle } from "lucide-react";
import { hasDeployedContracts } from "@/lib/contracts";
import { Card, CardContent } from "@/components/ui/card";

export function DeployBanner() {
  if (hasDeployedContracts()) return null;
  return (
    <Card className="border-amber-200/60 bg-amber-50/80 dark:border-amber-500/30 dark:bg-amber-950/40">
      <CardContent className="flex items-start gap-3 pt-6">
        <AlertCircle className="mt-0.5 h-5 w-5 shrink-0 text-amber-600" />
        <div className="text-sm text-amber-900 dark:text-amber-100">
          <p className="font-semibold">Contracts not configured</p>
          <p className="mt-1 text-amber-800/90 dark:text-amber-200/90">
            FindHunt: deploy to Hela Testnet and set{" "}
            <code className="rounded bg-white/60 px-1 dark:bg-black/30">NEXT_PUBLIC_*</code> in{" "}
            <code className="rounded bg-white/60 px-1 dark:bg-black/30">.env.local</code>. The app
            still runs for UI and wallet preview.
          </p>
        </div>
      </CardContent>
    </Card>
  );
}
