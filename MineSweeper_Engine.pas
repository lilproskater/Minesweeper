unit MineSweeper_Engine;

interface 
Uses GraphABC;

const CellSize = Round(ScreenHeight / 20);
const CellsInRow = 16;
const CellsInCol = 16;

procedure UpdateWindow();

type Cell = class
  x1, y1, x2, y2: integer;
  number: integer;
  contains_mine: boolean;
  revealed: boolean;
  flag_is_put: boolean;
  constructor Create(x,y: integer; mine: boolean);
  procedure Click(mouseButton: integer);
  procedure Draw();
end;

var grid: array [0..CellsInCol - 1, 0..CellsInRow - 1] of Cell;
    mine_is_pressed, first_click, victory: boolean;
    
implementation

procedure UpdateWindow();
begin
  try 
    Redraw();
  except
  
  end;
end;

constructor Cell.Create(x, y: integer; mine: boolean);
begin
  self.contains_mine := mine;
  self.x1 := x;
  self.y1 := y;
  self.x2 := self.x1 + CellSize;
  self.y2 := self.y1 + CellSize;
  self.revealed := false;
  self.flag_is_put := false;
end;

procedure Cell.Draw();
begin
  if self.revealed then SetBrushColor(rgb(153, 153, 153))
    else SetBrushColor(rgb(204, 204, 204));
  // Mine Color if self.contains_mine then SetBrushColor(clLime);
  if self.flag_is_put then SetBrushColor(clRed);
  Rectangle(self.x1, self.y1, self.x2, self.y2);
  //Number
  SetFontSize(20);
  SetFontName('Times New Roman');
  SetFontStyle(fsBold);
  if self.number = 1 then SetFontColor(rgb(0, 0, 255));
  if self.number = 2 then SetFontColor(rgb(0, 153, 0));
  if self.number = 3 then SetFontColor(rgb(255, 0, 0));
  if self.number = 4 then SetFontColor(rgb(0, 0, 153));
  if self.number = 5 then SetFontColor(rgb(102, 0, 0));
  if self.number = 6 then SetFontColor(rgb(163, 73, 164));
  if self.number = 7 then SetFontColor(rgb(255, 128, 0));
  if self.number = 8 then SetFontColor(rgb(0, 0, 0));
  if (self.number > 0) and (self.revealed) then DrawTextCentered(x1, y1, x2, y2, number);
end;

procedure Cell.Click(mouseButton: integer);
begin
  if (mouseButton = 1) and not (self.flag_is_put) then self.revealed := true;
  if (mouseButton = 1) and (self.revealed) and (self.contains_mine) then mine_is_pressed := true;
  if (mouseButton = 2) and not (self.revealed) then self.flag_is_put := not self.flag_is_put;
end;

begin
  mine_is_pressed := false;
end.
