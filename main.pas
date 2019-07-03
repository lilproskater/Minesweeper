Uses GraphABC, MineSweeper_Engine;

var grid: array [0..15, 0..15] of Cell;
    
procedure Init_Party();
begin
  var bomb_count := 40;
  for var y := 0 to 15 do
    for var x := 0 to 15 do
      grid[y, x] := new Cell(false);
  //Setting Up Bombs
  while bomb_count <> 0 do
  begin
    var x := Random(0, 15);
    var y := Random(0, 15);
    if not grid[y, x].contains_mine then grid[y, x].contains_mine := true
      else continue;
    bomb_count -= 1;
  end;
  
  //Setting x and y positions for each cell
  var pos_x := 0;
  var pos_y := 0;
  for var y := 0 to 15 do
    for var x := 0 to 15 do
    begin
      grid[y, x].x := pos_x;
      grid[y, x].y := pos_y;
      if pos_x + CellSize >= WindowWidth then
      begin
        pos_x := 0;
        pos_y += CellSize;
      end
      else pos_x += CellSize;
    end;
end;

procedure Draw_Grid();
begin
  for var y := 0 to 15 do
    for var x := 0 to 15 do
      grid[y, x].Draw();
  Redraw();
end;

procedure Main_SetUp();
begin
  SetWindowSize(16 * CellSize, 16 * CellSize);
  Window.CenterOnScreen;
  Window.IsFixedSize := true;
  Window.Title := 'MineSweeper';
  Init_Party();
end;

begin
  Main_SetUp();
  LockDrawing();
  while true do
    Draw_Grid();
end.
