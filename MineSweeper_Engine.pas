unit MineSweeper_Engine;

interface 
Uses GraphABC;

const CellSize = Round(ScreenHeight / 20);

type Cell = class
  x, y: integer;
  contains_mine: boolean;
  revealed: boolean;
  flag_is_put: boolean;
  constructor Create(mine: boolean);
  procedure Click(mouseButton: integer);
  procedure Draw();
end;


implementation

constructor Cell.Create(mine: boolean);
begin
  self.contains_mine := mine;
  self.x := 0;
  self.y := 0;
  self.revealed := false;
  self.flag_is_put := false;
end;

procedure Cell.Draw();
begin
  if self.revealed then SetBrushColor(rgb(187, 187, 187))
    else SetBrushColor(rgb(133, 133, 133));
  Rectangle(self.x, self.y, self.x + CellSize, self.y + CellSize);
end;

procedure Cell.Click(mouseButton: integer);
begin
  if mouseButton = 1 then self.revealed := true;
  //What if cell contains a bomb ??? ^^^ { if contains_mine then End_party(); }
  if mouseButton = 2 then self.flag_is_put := not self.flag_is_put;
end;


end.
