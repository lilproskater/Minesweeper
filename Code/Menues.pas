unit Menues;

interface
Uses GraphABC, MineSweeper_game;

var 
//Menues boolean
  main_menu, playing, statistics, settings, quit:boolean;

procedure MainMenu_Interface();
procedure MainMenu_MD(MouseX, MouseY, mouseButton: integer);
procedure Statistics_Interface();
procedure Statistics_MD(MouseX, MouseY, mouseButton: integer);
procedure Settings_Interface();
procedure Settings_MD(MouseX, MouseY, mouseButton: integer);
procedure MainMenu_KD(key: integer);
procedure Statistics_KD(key: integer);
procedure Settings_KD(key: integer);

implementation

type Button = class
  x1, y1, x2, y2: integer;
  text: string;
  constructor Create(x1_point, y1_point, x2_point, y2_point: integer; btn_text: string);
  begin
    x1 := x1_point;
    y1 := y1_point;
    x2 := x2_point;
    y2 := y2_point;
    text := btn_text;
  end;
  procedure Draw();
  begin
    Rectangle(x1, y1, x2, y2);
    DrawTextCentered(x1, y1, x2, y2, text);
  end;
  procedure Click();
  begin
  
  end;
end;

var 
//Genreal
    background: picture;
    btn_color, btn_border_color, font_color: color;
    pen_width: integer;

//MainMenu
    play_btn, stats_btn, settings_btn, quit_btn: button;    
    
    
procedure MainMenu_Interface();
begin
  background := new Picture('data/Background.png');
  background.Draw(0, 0, WindowWidth, WindowHeight);
  SetFontColor(font_color);
  SetFontSize(50);
  SetFontName('Tahoma');
  SetFontStyle(fsBold);
  DrawTextCentered(0, 0, WindowWidth, 120, 'MineSweeper');
  play_btn := new Button(120, 120, WindowWidth - 120, 220, 'Играть'); 
  stats_btn := new Button(120, 275, WindowWidth - 120, 375, 'Статистика'); 
  settings_btn := new Button(120, 430, WindowWidth - 120, 530, 'Настройки'); 
  quit_btn := new Button(120, 585, WindowWidth - 120, 685, 'Выход'); 
  SetPenColor(btn_border_color);
  SetBrushColor(btn_color);
  SetPenWidth(pen_width);
  SetFontSize(37);
  play_btn.Draw();
  stats_btn.Draw();
  settings_btn.Draw();
  quit_btn.Draw();
  Redraw();
end;

procedure MainMenu_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > play_btn.x1) and (MouseY > play_btn.y1) and (MouseX < play_btn.x2) and (MouseY < play_btn.y2) then 
  begin
    playing := true;
    Init_party();
  end;
  if (mouseButton = 1) and (MouseX > stats_btn.x1) and (MouseY > stats_btn.y1) and (MouseX < stats_btn.x2) and (MouseY < stats_btn.y2) then statistics := true;
  if (mouseButton = 1) and (MouseX > settings_btn.x1) and (MouseY > settings_btn.y1) and (MouseX < settings_btn.x2) and (MouseY < settings_btn.y2) then settings := true;
  if (mouseButton = 1) and (MouseX > quit_btn.x1) and (MouseY > quit_btn.y1) and (MouseX < quit_btn.x2) and (MouseY < quit_btn.y2) then quit := true;
end;

procedure Statistics_Interface();
begin
  background.Draw(0, 0, WindowWidth, WindowHeight);
  SetFontColor(font_color);
  SetFontSize(72);
  SetFontName('Tahoma');
  SetFontStyle(fsBold);
  DrawTextCentered(0, 0, WindowWidth, WindowHeight, 'Раздел в разработке');
  SetFontSize(50);
  Rectangle(20, WindowHeight - 120, 120, WindowHeight - 20);
  DrawTextCentered(20, WindowHeight - 120, 120, WindowHeight - 20, '←');
  Redraw();
end;

procedure Statistics_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > 20) and (MouseY > WindowHeight - 120) and (MouseX < 120) and (MouseY < WindowHeight - 20) then statistics := false;
end;

procedure Settings_Interface();
begin
  background.Draw(0, 0, WindowWidth, WindowHeight);
  SetFontColor(font_color);
  SetFontSize(72);
  SetFontName('Tahoma');
  SetFontStyle(fsBold);
  DrawTextCentered(0, 0, WindowWidth, WindowHeight, 'Раздел в разработке');
  SetFontSize(50);
  Rectangle(20, WindowHeight - 120, 120, WindowHeight - 20);
  DrawTextCentered(20, WindowHeight - 120, 120, WindowHeight - 20, '←');
  Redraw();
end;

procedure Settings_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > 20) and (MouseY > WindowHeight - 120) and (MouseX < 120) and (MouseY < WindowHeight - 20) then settings := false
end;

procedure MainMenu_KD(key: integer);
begin
  if key = VK_Enter then 
  begin
    playing := true;
    Init_party();
  end;
end;

procedure Statistics_KD(key: integer);
begin
  if key = VK_Escape then statistics := false;
end;

procedure Settings_KD(key: integer);
begin
  if key = VK_Escape then settings := false;
end;

begin
//General
  btn_color := rgb(185, 185, 185);
  btn_border_color := rgb(255, 255, 255);
  font_color := rgb(255, 255, 255);
  pen_width := 7;
end.