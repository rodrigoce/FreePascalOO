unit compra_rel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, RLReport;

type

  { TCompraRelForm }

  TCompraRelForm = class(TForm)
    RLBand1: TRLBand;
    RLBand2: TRLBand;
    RLBand3: TRLBand;
    RLBand4: TRLBand;
    rlPeriodo: TRLLabel;
    rlTitle: TRLLabel;
    RLReport1: TRLReport;
  private

  public
    class procedure Execute;
  end;

var
  CompraRelForm: TCompraRelForm;

implementation

{$R *.lfm}

{ TCompraRelForm }

class procedure TCompraRelForm.Execute;
begin
  Application.CreateForm(TCompraRelForm, CompraRelForm);
  with CompraRelForm do
  begin
    CompraRelForm.RLReport1.PreviewModal;
    CompraRelForm.Free;
  end;

end;

end.

