unit Menues;

interface

Uses GraphABC, MineSweeper_game;

var
//Menues boolean
  main_menu, playing, statistics, settings, quit: boolean;
 
procedure MainMenu_Interface();
procedure MainMenu_MD(MouseX, MouseY, mouseButton: integer);
procedure MainMenu_KU(key: integer);

procedure Statistics_Interface();
procedure Statistics_MD(MouseX, MouseY, mouseButton: integer);
procedure Statistics_KU(key: integer);

procedure Settings_Interface();
procedure Settings_MD(MouseX, MouseY, mouseButton: integer);
procedure Settings_KU(key: integer);

implementation
//Databases
const GameDB = 'data/data.dat';
const SettingsDB = 'data/settings.dat';

type
  Button = class
    x1, y1, x2, y2: integer;
    text: string;
    constructor Create(x1, y1, x2, y2: integer; text: string);
    begin
      self.x1 := x1;
      self.y1 := y1;
      self.x2 := x2;
      self.y2 := y2;
      self.text := text;
    end;
    
    procedure Draw();
    begin
      Rectangle(x1, y1, x2, y2);
      DrawTextCentered(x1, y1, x2, y2, text);
    end;
  end;

var
  //Genreal
  background: picture;
  btn_color, btn_border_color, font_color: color;
  pen_width: integer;
  filer: text;

  //MainMenu
  play_btn, stats_btn, settings_btn, quit_btn: button;
  
  //Statistics
  best_score, best_time: integer;
  
  //Settings
  level: string;
  change_level: boolean;
  
//-----------------------------  Private: Rewrite Statistics File  -----------------------------//
procedure Rewrite_statistics_file();
begin
  Rewrite(filer, GameDB);
  filer.Writeln(best_score);
  filer.Writeln(best_time);
  filer.Close();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Rewrite Settings File  -----------------------------//
procedure Rewrite_settings_file();
begin
  Rewrite(filer, SettingsDB);
  filer.Writeln(level);
  filer.Close();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Main Menu  -----------------------------//
procedure MainMenu_Interface();
begin
  background := new Picture('data/Background.png');
  background.Draw(0, 0, Width, Height);
  SetFontColor(font_color);
  SetFontSize(Round(Height / 14.4));
  SetFontName('Tahoma');
  SetFontStyle(fsBold);
  DrawTextCentered(0, 0, Width, Round(Height / 6), 'MineSweeper');
  play_btn := new Button(Round(Width / 6), Round(Height / 6), Width - Round(Width / 6), Round(Height / 3.272), 'Играть'); 
  stats_btn := new Button(Round(Width / 6), Round(Height / 2.618), Width - Round(Width / 6), Round(Height / 1.92), 'Статистика'); 
  settings_btn := new Button(Round(Width / 6), Round(Height / 1.674), Width - Round(Width / 6), Round(Height / 1.358), 'Настройки'); 
  quit_btn := new Button(Round(Width / 6), Round(Height / 1.23), Width - Round(Width / 6), Round(Height / 1.051), 'Выход');
  SetPenColor(btn_border_color);
  SetBrushColor(btn_color);
  SetPenWidth(pen_width);
  SetFontSize(Round(Height / 19.459));
  play_btn.Draw();
  stats_btn.Draw();
  settings_btn.Draw();
  quit_btn.Draw();
  Redraw();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Main Menu Mouse Down  -----------------------------//
procedure MainMenu_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > play_btn.x1) and (MouseY > play_btn.y1) and (MouseX < play_btn.x2) and (MouseY < play_btn.y2) then 
  begin
    playing := true;
    MineSweeper_game.SetUp();
    MineSweeper_game.Init_party();
  end;
  if (mouseButton = 1) and (MouseX > stats_btn.x1) and (MouseY > stats_btn.y1) and (MouseX < stats_btn.x2) and (MouseY < stats_btn.y2) then statistics := true;
  if (mouseButton = 1) and (MouseX > settings_btn.x1) and (MouseY > settings_btn.y1) and (MouseX < settings_btn.x2) and (MouseY < settings_btn.y2) then settings := true;
  if (mouseButton = 1) and (MouseX > quit_btn.x1) and (MouseY > quit_btn.y1) and (MouseX < quit_btn.x2) and (MouseY < quit_btn.y2) then quit := true;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Main Menu Key Up  -----------------------------//
procedure MainMenu_KU(key: integer);
begin
  if key = VK_Enter then 
  begin
    playing := true;
    MineSweeper_game.SetUp();
    MineSweeper_game.Init_party();
  end;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Statistics  -----------------------------//
procedure Statistics_Interface();
begin
  ClearWindow(rgb(185, 185, 185));
  best_score := 0; //Init value of best_score if file does not exist
  best_time := 99999999; //Init value of best_time if file does not exist
  try
    Reset(filer, GameDB);
    var best_score_handler, best_time_handler: string;
    Readln(filer, best_score_handler);
    Readln(filer, best_time_handler);
    filer.Close();
    //67500 is the max value of score (40 x 40 grid - bombsInGrid), where bombsInGrid = 250
    if (best_score_handler.ToInteger < 4) or (best_score_handler.ToInteger > 67500) then
      Rewrite_statistics_file()
    else
    begin
      best_score := best_score_handler.ToInteger;
      best_time := best_time_handler.ToInteger;
    end;
  except
    on System.Exception do
      Rewrite_statistics_file();
  end;
  SetFontSize(Round(Height / 20.517));
  DrawTextCentered(0, 0, Width, Round(Height / 7.2), 'Статистика');
  var best_time_to_string: string;
  if best_time = 99999999 then best_time_to_string := 'Нет лучшего времени'
  else best_time_to_string := best_time.ToString + ' сек.';
  SetFontSize(Round(Height / 36));
  TextOut(Round(Width / 32), Round(Height / 6), 'Лучший рекорд: ' + best_score + ' очка');
  TextOut(Round(Width / 32), Round(Height / 3.6), 'Лучшее время: ' + best_time_to_string);
  Redraw();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Statistics Mouse Down  -----------------------------//
procedure Statistics_MD(MouseX, MouseY, mouseButton: integer);
begin
  
end;
//-----------------------------------------------------------------------//


//-----------------------------  Statistics Key Up  -----------------------------//
procedure Statistics_KU(key: integer);
begin
  if key = VK_Escape then statistics := false;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Change Level Interface  -----------------------------//
procedure ChangeLevel_interface();
begin
  SetPenColor(rgb(255, 255, 255));
  SetBrushColor(clTransparent);
  SetFontColor(rgb(255, 255, 255));
  SetPenWidth(Round(Height / 102.835));
  SetFontSize(Round(Height / 36));
  Rectangle(Round(Width / 14.4), Round(Height / 14.4), Width - Round(Width / 14.4), Height - Round(Height / 14.4));
  DrawTextCentered(Round(Width / 14.4), Round(Height / 14.4), Width - Round(Width / 14.4), Round(Height / 6), 'Вырберите уровень сложности');
  Rectangle(Round(Width / 6.4), Round(Height / 4.8), Round(Width / 2.133), Round(Height / 2.05));
  Rectangle(Round(Width / 1.828), Round(Height / 4.8), Round(Width / 1.163), Round(Height / 2.05));
  Rectangle(Round(Width / 2.844), Round(Height / 1.8), Round(Width / 1.505), Round(Height / 1.2));
  DrawTextCentered(Round(Width / 6.4), Round(Height / 4.8), Round(Width / 2.133), Round(Height / 2.05), '8 × 8');
  DrawTextCentered(Round(Width / 1.828), Round(Height / 4.8), Round(Width / 1.163), Round(Height / 2.05), '16 × 16');
  DrawTextCentered(Round(Width / 2.844), Round(Height / 1.8), Round(Width / 1.505), Round(Height / 1.2), '40 × 40');
  Redraw();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Change Level Mouse Down  -----------------------------//
procedure ChangeLevel_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > Round(Width / 6.4)) and (MouseY > Round(Height / 4.8)) and (MouseX < Round(Width / 2.133)) and (MouseY < Round(Height / 2.05)) then
  begin
    level := 'low';
  end;
  if (mouseButton = 1) and (MouseX > Round(Width / 1.828)) and (MouseY > Round(Height / 4.8)) and (MouseX < Round(Width / 1.163)) and (MouseY < Round(Height / 2.05)) then 
  begin
    level := 'medium';
  end;
  if (mouseButton = 1) and (MouseX > Round(Width / 2.844)) and (MouseY > Round(Height / 1.8)) and (MouseX < Round(Width / 1.505)) and (MouseY < Round(Height / 1.2)) then
  begin
    level := 'hard';
  end;
  Rewrite_settings_file();
  change_level := false;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Change Level Key Up  -----------------------------//
procedure ChangeLevel_KU(key: integer);
begin
  if key = VK_Escape then change_level := false;  
end;
//-----------------------------------------------------------------------//


//-----------------------------  Settings  -----------------------------//
procedure Settings_Interface();
begin
  ClearWindow(rgb(185, 185, 185));
  level := 'medium'; //Init value of level if file does not exist
  try
    Reset(filer, SettingsDB);
    var level_handler: string;
    Readln(filer, level_handler);
    filer.Close();
    if (level_handler = 'low') or (level_handler = 'medium') or (level_handler = 'hard') then
      level := level_handler
    else
      Rewrite_settings_file();
  except
    on System.Exception do
      Rewrite_settings_file();
  end;
  while change_level do
  begin
    OnMouseDown := ChangeLevel_MD;
    OnKeyUp := ChangeLevel_KU;
    ChangeLevel_interface();
  end;
  SetFontSize(Round(Height / 20.517));
  DrawTextCentered(0, 0, Width, Round(Height / 7.2), 'Настройки');
  SetFontSize(Round(Height / 36));
  var level_translate: string;
  case level of
    'low': level_translate := '8 × 8';
    'medium': level_translate := '16 × 16';
    'hard': level_translate := '40 × 40';
  end;
  TextOut(Round(Width / 32), Round(Height / 6), 'Сложность: ');
  SetPenWidth(4);
  SetBrushColor(clTransparent);
  Rectangle(Round(Width / 3.2), Round(Height / 6.67), Round(Width / 1.6), Round(Height / 4.1));
  DrawTextCentered(Round(Width / 3.2), Round(Height / 6.67), Round(Width / 1.6), Round(Height / 4.1), level_translate);
  Redraw();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Settings Mouse Down  -----------------------------//
procedure Settings_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > Round(Width / 3.2)) and (MouseY > Round(Height / 6.67)) and (MouseX <  Round(Width / 1.6)) and (MouseY < Round(Height / 4.1)) then change_level := true;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Settings Key Up  -----------------------------//
procedure Settings_KU(key: integer);
begin
  if key = VK_Escape then settings := false;
end;
//-----------------------------------------------------------------------//


begin
  //General
  btn_color := rgb(185, 185, 185);
  btn_border_color := rgb(255, 255, 255);
  font_color := rgb(255, 255, 255);
  pen_width := Round(Height / 102.857);
end.
