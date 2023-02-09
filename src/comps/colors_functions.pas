unit colors_functions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, LCLType, LCLIntf;

{ Assumes R, G, B to be in range 0..255. Calculates H, S, V in range 0..1
  From: http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
  http://svn.code.sf.net/p/lazarus-ccr/svn/components/mbColorLib/RGBHSVUtils.pas}
procedure RGBToHSV(R, G, B: Integer; out H, S, V: Double);

{ Assumes H, S, V in the range 0..1 and calculates the R, G, B values which are
  returned to be in the range 0..255.
  From: http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
  http://svn.code.sf.net/p/lazarus-ccr/svn/components/mbColorLib/RGBHSVUtils.pas
}
procedure HSVtoRGB(H, S, V: Double; out R, G, B: Integer);

procedure TColorToRGB(Color: TColorRef; out R, G, B: Integer);

implementation

procedure RGBToHSV(R, G, B: Integer; out H, S, V: Double);
var
  rr, gg, bb: Double;
  cmax, cmin, delta: Double;
begin
  rr := R / 255;
  gg := G / 255;
  bb := B / 255;
  cmax := MaxValue([rr, gg, bb]);
  cmin := MinValue([rr, gg, bb]);
  delta := cmax - cmin;
  if delta = 0 then
  begin
    H := 0;
    S := 0;
  end else
  begin
    if cmax = rr then
      H := (gg - bb) / delta + IfThen(gg < bb, 6, 0)
    else if cmax = gg then
      H := (bb - rr) / delta + 2
    else if (cmax = bb) then
      H := (rr -gg) / delta + 4;
    H := H / 6;
    S := delta / cmax;
  end;
  V := cmax;
end;

procedure HSVtoRGB(H, S, V: Double; out R, G, B: Integer);
var
  i: Integer;
  f: Double;
  p, q, t: Double;

  procedure MakeRgb(rr, gg, bb: Double);
  begin
    R := Round(rr * 255);
    G := Round(gg * 255);
    B := Round(bb * 255);
  end;

begin
  i := floor(H * 6);
  f := H * 6 - i;
  p := V * (1 - S);
  q := V * (1 - f*S);
  t := V * (1 - (1 - f) * S);
  case i mod 6 of
    0: MakeRGB(V, t, p);
    1: MakeRGB(q, V, p);
    2: MakeRGB(p, V, t);
    3: MakeRGB(p, q, V);
    4: MakeRGB(t, p, V);
    5: MakeRGB(V, p, q);
    else MakeRGB(0, 0, 0);
  end;
end;

procedure TColorToRGB(Color: TColorRef; out R, G, B: Integer);
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);
end;

end.

