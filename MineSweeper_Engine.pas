unit MineSweeper_Engine;

interface

Uses GraphABC;

type
  Cell = class
    x1, y1, x2, y2: integer;
    number: integer;
    contains_mine: boolean;
    revealed: boolean;
    flag_is_put: boolean;
    constructor Create(x1, y1, x2, y2: integer; mine: boolean);
    procedure Click(mouseButton: integer);
    procedure Draw();
  end;

var
  mine_is_pressed, first_click: boolean;

implementation

constructor Cell.Create(x1, y1, x2, y2: integer; mine: boolean);
begin
  self.x1 := x1;
  self.y1 := y1;
  self.x2 := x2;
  self.y2 := y2;
  self.contains_mine := mine;
  self.revealed := false;
  self.flag_is_put := false;
end;

procedure Cell.Draw();
begin  
  Rectangle(self.x1, self.y1, self.x2, self.y2);
  //Number
  SetFontSize(Round(Abs(self.x2 - self.x1) / 2));
  if (self.number > 0) and (self.revealed) and not (self.contains_mine) then DrawTextCentered(x1, y1, x2, y2, self.number);
end;

procedure Cell.Click(mouseButton: integer);
begin
  if (mouseButton = 1) and not (self.flag_is_put) then self.revealed := true;
  if (mouseButton = 2) and not (self.revealed) and not (first_click) then self.flag_is_put := not self.flag_is_put;
  if (self.revealed) and (self.contains_mine) then mine_is_pressed := true;
end;
end.
