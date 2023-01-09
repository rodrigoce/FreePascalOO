unit PanelX;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TPanelX }

  TPanelX = class(TPanel)
  private

  protected
    procedure Paint; override;
    procedure SetEnabled(Value: Boolean); override;
  public

  published

  end;

procedure Register;

implementation

procedure Register;
begin
  {$I panelx_icon.lrs}
  RegisterComponents('Comps',[TPanelX]);
end;

{ TPanelX }

procedure TPanelX.Paint;
var p : TPoint;
begin
  inherited Paint;
  if not Enabled then
  begin
    Canvas.Pen.Color := clGray;//clRed;
    Canvas.Pen.Width := 2;
    p.X := 1 + BevelWidth;
    p.Y := 1 + BevelWidth;
    Canvas.PenPos := p;
    Canvas.LineTo(Width - 1 - BevelWidth,Height - 1 - BevelWidth);
    p.X := 1 + BevelWidth;
    p.Y := Height - 1 - BevelWidth;
    Canvas.PenPos := p;
    Canvas.LineTo(Width - 1 - BevelWidth, 1 + BevelWidth);
  end;
end;

procedure TPanelX.SetEnabled(Value: Boolean);
begin
    if Value then
    Color := clBtnFace
  else
    Color := clInactiveBorder;

  inherited SetEnabled(Value);
  Invalidate;
  Update;
end;

end.
