// Top header bar — brand logo, user avatar/name/role, sign-out button; used in AppLayout
import { useAuth } from "@/hooks/useAuth";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Wrench, LogOut } from "lucide-react";

export function TopBar({ onSignOut }) {
  const { user } = useAuth();
  const initials = user?.name
    ? user.name
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
        .slice(0, 2)
    : "??";

  return (
    <header className="flex h-14 items-center justify-between border-b border-border bg-background px-4 md:px-6">
      <div className="flex items-center gap-2">
        <Wrench className="h-5 w-5 text-coral" />
        <span className="text-lg font-bold text-foreground">TechFix</span>
      </div>

      <div className="flex items-center gap-3">
        <div className="text-right text-sm">
          <p className="font-medium text-foreground">{user?.name}</p>
          <p className="text-xs text-muted-foreground">{user?.role}</p>
        </div>
        <Avatar className="h-8 w-8">
          <AvatarFallback className="bg-coral text-xs text-primary-foreground">
            {initials}
          </AvatarFallback>
        </Avatar>
        <Button variant="ghost" size="icon" onClick={onSignOut} className="text-grey hover:text-destructive">
          <LogOut className="h-4 w-4" />
        </Button>
      </div>
    </header>
  );
}
