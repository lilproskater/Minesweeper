Uses GraphABC, MineSweeper_Engine;

var grid: array [0..15, 0..15] of Cell;
    
procedure Init_Party();
begin
  //Firstly setting all cells empty
  //Setting x and y positions for each cell
  var pos_x := 0;
  var pos_y := 0;
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
    begin
      grid[y, x] := new Cell(pos_x, pos_y, false);
      if pos_x + CellSize >= WindowWidth then
      begin
        pos_x := 0;
        pos_y += CellSize;
      end
      else pos_x += CellSize;  
    end;
  
  //Setting Up Bombs
  var bomb_count := 40;
  while bomb_count <> 0 do
  begin
    var x := Random(0, CellsInRow - 1);
    var y := Random(0, CellsInRow - 1);
    if not grid[y, x].contains_mine then grid[y, x].contains_mine := true
      else continue;
    bomb_count -= 1;
  end;
end;

procedure EndParty();
begin
  //End Game Interface
  ClearWindow(clBlack);
  Redraw();
end;

procedure Draw_Grid();
begin
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
      grid[y, x].Draw();
  Redraw();
end;

procedure MouseUp(MouseX, MouseY, mouseButton: integer);
begin
  Window.Title := 'MouseX: ' + MouseX + ' MouseY: ' + MouseY;
  if not EndGame then
  begin
    //Realize pressing cells
    grid[Ceil(MouseY / (WindowHeight / CellsInRow)) - 1, Ceil(MouseX / (WindowWidth / CellsInRow)) - 1].Click(mouseButton);
  end;
end;

procedure Main_SetUp();
begin
  SetWindowSize(16 * CellSize, 16 * CellSize);
  Window.CenterOnScreen;
  Window.IsFixedSize := true;
  Window.Title := 'MineSweeper';
  Init_Party();
  LockDrawing();
  OnMouseUp := MouseUp;
end;

begin
  Main_SetUp();
  while true do
  begin
    if not EndGame then
      Draw_Grid()
    else 
      EndParty();
  end;
end.
