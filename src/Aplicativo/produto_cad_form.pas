unit produto_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, SpinEx, produto_entity, produto_bll, application_types;

type

  { TProdutoCadForm }

  TProdutoCadForm = class(TForm)
    btCancel: TButton;
    btSave: TButton;
    edId: TEdit;
    edNome: TEdit;
    edReferencia: TEdit;
    edPrecoCusto: TFloatSpinEdit;
    edMargemLucro: TFloatSpinEdit;
    edPrecoVenda: TFloatSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
  private
    FProduto: TProdutoEntity;
    FProdutoBLL: TProdutoBLL;
    FIsInsert: Boolean;
    procedure ObjectToView;
    procedure ViewToObject;
  public
    class procedure Edit(Id: Integer);
  end;

var
  ProdutoCadForm: TProdutoCadForm;

implementation

{$R *.lfm}

{ TProdutoCadForm }

procedure TProdutoCadForm.btSaveClick(Sender: TObject);
var
  opResult: TOperationResult;
begin
  ViewToObject;

  if FIsInsert then
  begin
    opResult := FProdutoBLL.InsertProduto(FProduto)
  end
  else
    opResult := FProdutoBLL.UpdateProduto(FProduto);

  if opResult.Success then
    Close
  else
    ShowMessage(opResult.Message + LineEnding + FProduto.GetAllRawErrorMessages);
end;

procedure TProdutoCadForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TProdutoCadForm.ObjectToView;
begin
  edId.Text := FProduto.Id.ToString;
  edReferencia.Text := FProduto.Referencia;
  edNome.Text := FProduto.Nome;
  edPrecoCusto.Value := FProduto.PrecoCusto;
  edMargemLucro.Value := FProduto.MargemLucro;
  edPrecoVenda.Value := FProduto.PrecoVenda;
end;

procedure TProdutoCadForm.ViewToObject;
begin
  FProduto.Referencia := edReferencia.Text;
  FProduto.Nome := edNome.Text;
  FProduto.PrecoCusto := edPrecoCusto.Value;
  FProduto.MargemLucro := edMargemLucro.Value;
  FProduto.PrecoVenda := edPrecoVenda.Value;
end;

class procedure TProdutoCadForm.Edit(Id: Integer);
begin
  Application.CreateForm(TProdutoCadForm, ProdutoCadForm);
  with ProdutoCadForm do
  begin
    FProdutoBLL := TProdutoBLL.Create;

    if Id = 0 then
    begin
      FProduto := FProdutoBLL.NewProduto;
      FIsInsert := True;
    end
    else
    begin
      FProduto := FProdutoBLL.FindProdutoByPK(Id);
      FIsInsert := False;
    end;
    ObjectToView;

    ShowModal;
    FProduto.Free;
    FProdutoBLL.Free;
  end;
end;

end.

