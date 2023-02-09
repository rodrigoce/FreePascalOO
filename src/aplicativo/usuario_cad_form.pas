unit usuario_cad_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls,
  ExtCtrls, usuario_entity, usuario_bll, application_types,
  mensagem_validacao_form, prop_to_comp_map, db_context, PanelTitle;

type

  { TUsuarioCadForm }

  TUsuarioCadForm = class(TForm)
    barAcoes: TPanelTitle;
    btCancel: TButton;
    btSave: TButton;
    ckAtivo: TCheckBox;
    edId: TEdit;
    edNome: TEdit;
    edUserName: TEdit;
    edSenha: TEdit;
    labId: TLabel;
    labNome: TLabel;
    labUserName: TLabel;
    labSenha: TLabel;
    leftFlowPanel: TFlowPanel;
    rightFlowPanel: TFlowPanel;
    procedure btCancelClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure edUserNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edUserNameKeyPress(Sender: TObject; var Key: char);
  private
    FUsuario: TUsuarioEntity;
    FUsuarioBLL: TUsuarioBLL;
    FPropToCompMap: TPropToCompMap;
    procedure ConfigMapPropComp;
    procedure Save;
  public
    class procedure Edit(Id: Integer);
  end;

var
  UsuarioCadForm: TUsuarioCadForm;

implementation

{$R *.lfm}

{ TUsuarioCadForm }

procedure TUsuarioCadForm.btSaveClick(Sender: TObject);
begin
  try
    btSave.Enabled := False;
    Save;
  finally
    btSave.Enabled := True;
  end;
end;

procedure TUsuarioCadForm.edUserNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TUsuarioCadForm.edUserNameKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['a'..'z', 'A'..'Z', #8]) then
    Key := #0;
end;

procedure TUsuarioCadForm.ConfigMapPropComp;
begin
  FPropToCompMap.MapEditWithNumbersOnly('Id', edId, labId);
  FPropToCompMap.MapEdit('Nome', edNome, 60, labNome);
  FPropToCompMap.MapEdit('UserName', edUserName, 30, labUserName);
  FPropToCompMap.MapCharCheckbox('Situacao', ckAtivo, 'A', 'I');
  FPropToCompMap.MapEdit('Senha', edSenha, 200, labSenha);
end;

procedure TUsuarioCadForm.Save;
var
  opResult: TOperationResult;
begin
  FPropToCompMap.CompToObject(FUsuario);

  opResult := FUsuarioBLL.AddOrUpdateUsuario(FUsuario);

  if opResult.Success then
    Close
  else
    TMensagemValidacaoForm.Open(opResult.Message, FUsuario, FPropToCompMap);
end;

procedure TUsuarioCadForm.btCancelClick(Sender: TObject);
begin
  Close;
end;

class procedure TUsuarioCadForm.Edit(Id: Integer);
begin
  Application.CreateForm(TUsuarioCadForm, UsuarioCadForm);
  with UsuarioCadForm do
  begin
    FUsuarioBLL := TUsuarioBLL.Create(gAppDbContext);
    FPropToCompMap := TPropToCompMap.Create;

    ConfigMapPropComp;

    if Id = 0 then
    begin
      FUsuario := FUsuarioBLL.NewUsuario;
    end
    else
    begin
      edSenha.Enabled := False;
      FUsuario := FUsuarioBLL.InnerDAL.FindByPK(Id);
    end;

    FPropToCompMap.ObjectToComp(FUsuario);

    ShowModal;

    FUsuarioBLL.Free;
    FPropToCompMap.Free;

    FUsuario.Free;
    Free;
  end;
end;

end.

