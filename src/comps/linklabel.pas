unit LinkLabel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TLinkLabel }

  TLinkLabel = class(TLabel)
  private
    procedure MouseEntra(Sender: TObject);
    procedure MouseSai(Sender: TObject);
  protected

  public
    constructor Create(AOwner: TComponent); override;
  published

  end;

procedure Register;

implementation

procedure Register;
begin
  {$I linklabel_icon.lrs}
  RegisterComponents('Comps',[TLinkLabel]);
end;

{ TLinkLabel }

procedure TLinkLabel.MouseEntra(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
    Self.Font.Color := clRed;
end;

procedure TLinkLabel.MouseSai(Sender: TObject);
begin
  if not (csDesigning in ComponentState) then
    Self.Font.Color := clBlue;
end;

constructor TLinkLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Font.Color := clBlue;
  Font.Style := [fsUnderLine];
  Cursor := crHandPoint;
  OnMouseEnter := @MouseEntra;
  OnMouseLeave := @MouseSai;
  Repaint;
end;

end.
