unit MineSweeper_Engine;

interface 
Uses GraphABC;

const CellSize = Round(ScreenHeight / 20);
const CellsInRow = 16;

var bomb_is_pressed: boolean;

type Cell = class
  x1, y1, x2, y2: integer;
  contains_mine: boolean;
  revealed: boolean;
  flag_is_put: boolean;
  constructor Create(x,y: integer; mine: boolean);
  procedure Click(mouseButton: integer);
  procedure Draw();
end;


implementation

constructor Cell.Create(x, y: integer; mine: boolean);
begin
  self.contains_mine := mine;
  self.x1 := x;
  self.y1 := y;
  self.x2 := self.x1 + CellSize;
  self.y2 := self.y2 + CellSize;
  self.revealed := false;
  self.flag_is_put := false;
end;

procedure Cell.Draw();
begin
  if self.revealed then SetBrushColor(rgb(187, 187, 187))
    else SetBrushColor(rgb(133, 133, 133));
  if self.contains_mine then SetBrushColor(clRed);
  Rectangle(self.x1, self.y1, self.x1 + CellSize, self.y1 + CellSize);
end;

procedure Cell.Click(mouseButton: integer);
begin
  if mouseButton = 1 then self.revealed := true;
  if (mouseButton = 1) and (self.contains_mine) then bomb_is_pressed := true;
  if mouseButton = 2 then self.flag_is_put := not self.flag_is_put;
end;

begin
  bomb_is_pressed := false;
end.
