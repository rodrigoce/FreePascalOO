unit fornecedor_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Forms, Controls, StdCtrls,
  ExtCtrls, fornecedor_entity, fornecedor_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map, db_context;

type

  { TFornecedorCadForm }

  TFornecedorCadForm = class(TForm)
    btCancel: TButton;
    btSave: TButton;
    ckAtivo: TCheckBox;
    edId: TEdit;
    edNome: TEdit;
    labContatos: TLabel;
    labId: TLabel;
    labNome: TLabel;
    memoContatos: TMemo;
    Panel1: TPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
  private
    FFornecedor: TFornecedorEntity;
    FFornecedorBLL: TFornecedorBLL;
    FPropToCompMap: TPropToCompMap;
    procedure ConfigMapPropComp;
  public
    class procedure Edit(Id: Integer);
  end;

var
  FornecedorCadForm: TFornecedorCadForm;

implementation

{$R *.lfm}

{ TFornecedorCadForm }

procedure TFornecedorCadForm.btSaveClick(Sender: TObject);
var
  opResult: TOperationResult;
begin
  try
    btSave.Enabled := False;
    FPropToCompMap.CompToObject(FFornecedor);

    opResult := FFornecedorBLL.AddOrUpdateFornecedor(FFornecedor);

    if opResult.Success then
      Close
    else
      TMensagemValidacaoForm.Open(opResult.Message, FFornecedor, FPropToCompMap);
  finally
    btSave.Enabled := True;
  end;
end;

procedure TFornecedorCadForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEditWithNumbersOnly('Id', edId, labId);
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapMemo('Contatos', memoContatos, 500, labContatos);
  FPropToCompMap.MapCharCheckbox('Situacao', ckAtivo, 'A', 'I');
end;

procedure TFornecedorCadForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

class procedure TFornecedorCadForm.Edit(Id: Integer);
begin
  Application.CreateForm(TFornecedorCadForm, FornecedorCadForm);
  with FornecedorCadForm do
  begin
    FFornecedorBLL := TFornecedorBLL.Create(gAppDbContext);
    FPropToCompMap := TPropToCompMap.Create;

    ConfigMapPropComp;

    if Id = 0 then
    begin
      FFornecedor := FFornecedorBLL.NewFornecedor;
    end
    else
    begin
      FFornecedor := FFornecedorBLL.InnerDAL.FindByPK(Id);
    end;

    FPropToCompMap.ObjectToComp(FFornecedor);

    ShowModal;

    FFornecedorBLL.Free;
    FPropToCompMap.Free;

    FFornecedor.Free;
    Free;
  end;
end;

end.

