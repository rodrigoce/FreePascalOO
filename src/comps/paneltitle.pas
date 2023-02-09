unit PanelTitle;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LCLIntf, LCLType, StrUtils, colors_functions;

type

  { TPanelTitle }

  TPanelTitle = class(TPanel)
  private
    FHSVIncrease: string;
    FFixedHeight: Integer;
    FShowBorder: Boolean;
    //FAnotherCanvas: TControlCanvas;
    FTitle: string;
    procedure SetHSVIncrease(AValue: string);
    procedure SetFixedHeight(AValue: Integer);
    procedure SetShowBorder(AValue: Boolean);
    procedure SetTitle(AValue: string);
    procedure PanelResize(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(TheOwner: TComponent); override;
    //destructor Destroy; override;
  published
    property Title: string read FTitle write SetTitle;
    property FixedHeight: Integer read FFixedHeight write SetFixedHeight default 0;
    // setar como H, S ou V, o Default é S
    property HSVIncrease: string read FHSVIncrease write SetHSVIncrease;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder;
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

procedure TPanelTitle.SetFixedHeight(AValue: Integer);
begin
  if FFixedHeight = AValue then Exit;
  FFixedHeight := AValue;
  PanelResize(Self);
end;

procedure TPanelTitle.SetShowBorder(AValue: Boolean);
begin
  if FShowBorder = AValue then Exit;
  FShowBorder := AValue;
  Invalidate;
end;

procedure TPanelTitle.SetHSVIncrease(AValue: string);
begin
  if FHSVIncrease = AValue then Exit;
  FHSVIncrease := AValue;
  Invalidate;
end;

procedure TPanelTitle.PanelResize(Sender: TObject);
begin
  if FixedHeight > 0 then
    Height := FixedHeight;
end;

procedure TPanelTitle.Paint;
  var
    textWidth : Integer;
    R, G, B: Integer;
    H, S, V: Double;
begin
  inherited Paint;
  {if FAnotherCanvas.Control = nil then
  begin
    FAnotherCanvas := TControlCanvas.Create;
    FAnotherCanvas.Control := Self;
  end;}

  //Canvas.Pen.Width := 1;
  //Canvas.Font.Color := Darker2(Self.Color, 60);

  Canvas.Pen.EndCap := pecSquare;

  // faz um retangulo baseado na cor do panel
  TColorToRGB(Color, R, G, B);
  RGBToHSV(R, G, B, H, S, V);

  if FHSVIncrease = 'H' then
  begin
    H := H + 0.15;
    if H > 1 then
      H := H - 1;
  end
  else if FHSVIncrease = 'V' then
  begin
    V := V - 0.15;
      if V < 1 then
        V := V + 1;
  end
  else
  begin
    S := S + 0.15;
    if S > 1 then
      S := S - 1;
  end;

  HSVtoRGB(H, S, V, R, G, B);
  Canvas.Pen.Color := RGB(R, G, B);

  if ShowBorder then
    Canvas.Rectangle(0, 0, Width, Height);

  if not IsEmptyStr(Title, [' ']) then
  begin
    // faz dois riscos de destaque
    Canvas.Line(5, 4, 26, 4); // comprimento 20 px
    Canvas.Line(9, 8, 26, 8); // comprimento 20 px

    textWidth := Canvas.TextWidth(FTitle);
    Canvas.Line(textWidth + 34, 4, 30 + textWidth + 25, 4);
    Canvas.Line(textWidth + 34, 8, 30 + textWidth + 21, 8);

    // escreve o título
    Canvas.Brush.Color := Color;
    Canvas.TextOut(30, 0, FTitle);

  end;
end;

constructor TPanelTitle.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  OnResize := @PanelResize;
end;

{destructor TPanelTitle.Destroy;
begin
  if FAnotherCanvas <> nil then;
    FAnotherCanvas.Destroy;
  inherited Destroy;
end;}

end.
