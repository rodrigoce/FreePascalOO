unit pascal_code_generator_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, StdCtrls, StrUtils;

type

  { TPascalCodeGeneratorForm }

  TPascalCodeGeneratorForm = class(TForm)
    btGerarTelaCadastro: TButton;
    btGerarEntidade: TButton;
    btGerarFilter: TButton;
    btGerarFilterValidator: TButton;
    btGerarDAL: TButton;
    btGerarTelaManutencao: TButton;
    btGerarValidator: TButton;
    btGerarBLL: TButton;
    edNomeMaiusculo: TEdit;
    edNomeMinusculo: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure btGerarBLLClick(Sender: TObject);
    procedure btGerarDALClick(Sender: TObject);
    procedure btGerarEntidadeClick(Sender: TObject);
    procedure btGerarFilterClick(Sender: TObject);
    procedure btGerarFilterValidatorClick(Sender: TObject);
    procedure btGerarTelaCadastroClick(Sender: TObject);
    procedure btGerarTelaManutencaoClick(Sender: TObject);
    procedure btGerarValidatorClick(Sender: TObject);
  private
    path: string;

    sl: TStringList;
    function PreGeracao: Boolean;
    procedure PosGeracao;
  public
    class procedure Open;
  end;

var
  PascalCodeGeneratorForm: TPascalCodeGeneratorForm;

implementation

{$R *.lfm}

{ TPascalCodeGeneratorForm }

procedure TPascalCodeGeneratorForm.btGerarEntidadeClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_entity.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_entity.pas');
end;

procedure TPascalCodeGeneratorForm.btGerarDALClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_dal.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_dal.pas');
end;

procedure TPascalCodeGeneratorForm.btGerarBLLClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_bll.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_bll.pas');

end;

procedure TPascalCodeGeneratorForm.btGerarFilterClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_filter.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_filter.pas');

end;

procedure TPascalCodeGeneratorForm.btGerarFilterValidatorClick(Sender: TObject
  );
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_filter_validator.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_filter_validator.pas');

end;

procedure TPascalCodeGeneratorForm.btGerarTelaCadastroClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_cad_form.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_cad_form.pas');

  sl.LoadFromFile(path + 'produto_cad_form.lfm');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_cad_form.lfm');

end;

procedure TPascalCodeGeneratorForm.btGerarTelaManutencaoClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_man_form.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_man_form.pas');

  sl.LoadFromFile(path + 'produto_man_form.lfm');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_man_form.lfm');
end;

procedure TPascalCodeGeneratorForm.btGerarValidatorClick(Sender: TObject);
var
  i: Integer;
begin
  if not PreGeracao then Exit;

  sl.LoadFromFile(path + 'produto_validator.pas');

  for i := 0 to sl.Count -1 do
  begin
    sl[i] := StringReplace(sl[i], 'produto', edNomeMinusculo.Text, [rfReplaceAll]);
    sl[i] := StringReplace(sl[i], 'Produto', edNomeMaiusculo.Text, [rfReplaceAll]);
  end;

  sl.SaveToFile(path + edNomeMinusculo.Text + '_validator.pas');

end;

function TPascalCodeGeneratorForm.PreGeracao: Boolean;
begin
  Result := False;
  if IsEmptyStr(edNomeMaiusculo.Text, [' ']) or IsEmptyStr(edNomeMinusculo.Text, [' ']) then
  begin
    ShowMessage('Preencha os nomes.');
    Exit;
  end;

  path := 'D:\Rodrigo\FreePascalOO\src\Aplicativo\';

  sl := TStringList.Create;

  Result := True;
end;

procedure TPascalCodeGeneratorForm.PosGeracao;
begin
  sl.Free;
end;

class procedure TPascalCodeGeneratorForm.Open;
begin
  Application.CreateForm(TPascalCodeGeneratorForm, PascalCodeGeneratorForm);
  with PascalCodeGeneratorForm do
  begin
    ShowModal;
    Free;
  end;
end;

end.

