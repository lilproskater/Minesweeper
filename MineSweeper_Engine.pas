unit MineSweeper_Engine;

interface 
Uses GraphABC;

type Cell = class
  x1, y1, x2, y2: integer;
  number: integer;
  contains_mine: boolean;
  revealed: boolean;
  flag_is_put: boolean;
  constructor Create(x1,y1, x2, y2: integer; mine: boolean);
  procedure Click(mouseButton: integer);
  procedure Draw();
end;

var mine_is_pressed, first_click: boolean;
    
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
  //Cell color
  if revealed then SetBrushColor(rgb(153, 153, 153))
    else SetBrushColor(rgb(204, 204, 204));
  
  //Flag Color
  if flag_is_put then SetBrushColor(clRed);
  
  // Mine Color 
  if (contains_mine) and (mine_is_pressed) then SetBrushColor(rgb(0, 0, 0));
  
  Rectangle(x1, y1, x2, y2);
  
  //Number
  SetFontSize(20);
  SetFontName('Times New Roman');
  SetFontStyle(fsBold);
  
  //Setting Color of Font Depending on Number 
    case number of
      1: SetFontColor(rgb(0, 0, 255));
      2: SetFontColor(rgb(0, 153, 0));
      3: SetFontColor(rgb(255, 0, 0));
      4: SetFontColor(rgb(0, 0, 153));
      5: SetFontColor(rgb(102, 0, 0));
      6: SetFontColor(rgb(163, 73, 164));
      7: SetFontColor(rgb(255, 128, 0));
      8: SetFontColor(rgb(0, 0, 0));
    end;
  if (number > 0) and (revealed) and not (contains_mine) then DrawTextCentered(x1, y1, x2, y2, number);
end;

procedure Cell.Click(mouseButton: integer);
begin
  if (mouseButton = 1) and not (flag_is_put) then revealed := true;
  if (mouseButton = 2) and not (revealed) and not (first_click) then flag_is_put := not flag_is_put;
  if (revealed) and (contains_mine) then mine_is_pressed := true;
end;
end.
