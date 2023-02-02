unit PanelTitle;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LCLIntf, LCLType;

type

  { TPanelTitle }

  TPanelTitle = class(TPanel)
  private
    //FAnotherCanvas: TControlCanvas;
    FTitle: string;
    procedure SetTitle(AValue: string);
  protected
    procedure Paint; override;
  public
    //constructor Create(TheOwner: TComponent); override;
    //destructor Destroy; override;
  published
    property Title: string read FTitle write SetTitle;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I paneltitle_icon.lrs}
  RegisterComponents('Comps', [TPanelTitle]);
end;

{ TPanelTitle }

procedure TPanelTitle.SetTitle(AValue: string);
begin
  if FTitle = AValue then Exit;
  FTitle := AValue;
  Invalidate;
end;

procedure TPanelTitle.Paint;

  {function Darker2(MyColor:TColor; Percent:Byte):TColor;
  var r,g,b:Byte;
  begin
    MyColor:=ColorToRGB(MyColor);
    r:=GetRValue(MyColor);
    g:=GetGValue(MyColor);
    b:=GetBValue(MyColor);
    r:=r-muldiv(r,Percent,100);  //Percent% closer to black
    g:=g-muldiv(g,Percent,100);
    b:=b-muldiv(b,Percent,100);
    result:=RGB(r,g,b);
  end;
  function Lighter2(MyColor:TColor; Percent:Byte):TColor;
  var r,g,b:Byte;
  begin
    MyColor:=ColorToRGB(MyColor);
    r:=GetRValue(MyColor);
    g:=GetGValue(MyColor);
    b:=GetBValue(MyColor);
    r:=r+muldiv(255-r,Percent,100); //Percent% closer to white
    g:=g+muldiv(255-g,Percent,100);
    b:=b+muldiv(255-b,Percent,100);
    result:=RGB(r,g,b);
  end;}
  var textWidth : Integer;
begin
  inherited Paint;
  {if FAnotherCanvas.Control = nil then
  begin
    FAnotherCanvas := TControlCanvas.Create;
    FAnotherCanvas.Control := Self;
  end;}
  //Canvas.TextOut(10,50, '....................');
  Canvas.Pen.Color := clGray;
  //Canvas.Pen.Width := 1;
  Canvas.Pen.EndCap := pecSquare;
  //Canvas.Font.Color := Darker2(Self.Color, 60);
  //Canvas.Brush.Color := Self.Color;

  Canvas.Line(5, 6, 25, 6); // comprimento 20
  Canvas.Line(5, 8, 25, 8); // comprimento 20
  Canvas.TextOut(30, 0, FTitle);
  textWidth := Canvas.TextWidth(FTitle);
  Canvas.Line(textWidth + 35, 6, 30 + textWidth + 25, 6);
  Canvas.Line(textWidth + 35, 8, 30 + textWidth + 25, 8);
end;

{constructor TPanelTitle.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
end;}

{destructor TPanelTitle.Destroy;
begin
  if FAnotherCanvas <> nil then;
    FAnotherCanvas.Destroy;
  inherited Destroy;
end;}

end.
