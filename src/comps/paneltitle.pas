unit PanelTitle;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TPanelTitle }

  TPanelTitle = class(TPanel)
  private

  protected
    procedure Paint; override;

  public

  published

  end;

procedure Register;

implementation

procedure Register;
begin
  {$I paneltitle_icon.lrs}
  RegisterComponents('Comps', [TPanelTitle]);
end;

{ TPanelTitle }

procedure TPanelTitle.Paint;
begin
  inherited Paint;
end;

end.
