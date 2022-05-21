unit produto_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, SpinEx, produto_entity, produto_dal;

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
    FProdutoEntity: TProdutoEntity;
    FProdutoDal: TProdutoDal;
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
begin
  ViewToObject;

  if FIsInsert then
  begin
    FProdutoEntity.Id:= FProdutoDal.GetNextSequence;
    FProdutoDal.Insert(FProdutoEntity)
  end
  else
    FProdutoDal.Update(FProdutoEntity);
  Close;
end;

procedure TProdutoCadForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TProdutoCadForm.ObjectToView;
begin
  edId.Text := FProdutoEntity.Id.ToString;
  edReferencia.Text := FProdutoEntity.Referencia;
  edNome.Text := FProdutoEntity.Nome;
  edPrecoCusto.Value := FProdutoEntity.PrecoCusto;
  edMargemLucro.Value := FProdutoEntity.MargemLucro;
  edPrecoVenda.Value := FProdutoEntity.PrecoVenda;
end;

procedure TProdutoCadForm.ViewToObject;
begin
  FProdutoEntity.Referencia := edReferencia.Text;
  FProdutoEntity.Nome := edNome.Text;
  FProdutoEntity.PrecoCusto := edPrecoCusto.Value;
  FProdutoEntity.MargemLucro := edMargemLucro.Value;
  FProdutoEntity.PrecoVenda := edPrecoVenda.Value;
end;

class procedure TProdutoCadForm.Edit(Id: Integer);
begin
  Application.CreateForm(TProdutoCadForm, ProdutoCadForm);
  with ProdutoCadForm do
  begin
    FProdutoDal := TProdutoDal.Create;

    if Id = 0 then
    begin
      FProdutoEntity := TProdutoEntity.Create;
      FIsInsert := True;
    end
    else
    begin
      FProdutoEntity := FProdutoDal.FindByPK(Id);
      FIsInsert := False;
    end;
    ObjectToView;

    ShowModal;
    FProdutoEntity.Free;
    FProdutoDal.Free;
  end;
end;

end.

