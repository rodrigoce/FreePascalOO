unit BBarPanel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TBBarPanel }

  TBBarPanel = class(TPanel)
  private

    procedure PanelResize(Sender: TObject);
  protected

  public
    constructor Create(AOwner: TComponent); override;

  published

  end;

procedure Register;

implementation

procedure Register;
begin
  {$I bbarpanel_icon.lrs}
  RegisterComponents('Comps', [TBBarPanel]);
end;

{ TBBarPanel }

procedure TBBarPanel.PanelResize(Sender: TObject);
begin
  Height := 35;
end;

constructor TBBarPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Height := 35;
  Width := 500;
  BevelOuter := bvNone;
  BorderWidth := 5;
  Color := clSkyBlue;
  ParentColor := False;
  OnResize := @PanelResize;
end;

end.
