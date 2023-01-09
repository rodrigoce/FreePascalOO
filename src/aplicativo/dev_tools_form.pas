unit dev_tools_form;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, sqldb, DBGrids, ComCtrls, Spin, Types;

type

  { TDevToolsForm }

  TDevToolsForm = class(TForm)
    ckEnableTracer: TCheckBox;
    memoLogTConnection: TMemo;
    pageTools: TPageControl;
    q_so_para_ver_as_props: TSQLQuery;
    Splitter1: TSplitter;
    pageQueriesResults: TPageControl;
    tabQuery: TTabSheet;
    Grade: TDBGrid;
    pnBtsOfQueries: TPanel;
    labPos: TLabel;
    edConta: TSpinEdit;
    btFechaCon: TButton;
    tabQueryText: TTabSheet;
    edResult: TMemo;
    pnSQLRunner: TPanel;
    pnBtsSQLRunner: TPanel;
    btExec: TButton;
    edInstrucao: TMemo;
    btExport: TButton;
    Salvar: TSaveDialog;
    btHTML: TButton;
    btLimpa: TButton;
    btSalva: TButton;
    btAbre: TButton;
    Abrir: TOpenDialog;
    tabSQLRunner: TTabSheet;
    tabSQLTracer: TTabSheet;
    procedure btExecClick(Sender: TObject);
    procedure ckEnableTracerChange(Sender: TObject);
    procedure edContaChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btFechaConClick(Sender: TObject);
    procedure btExportClick(Sender: TObject);
    procedure btHTMLClick(Sender: TObject);
    procedure btLimpaClick(Sender: TObject);
    procedure btSalvaClick(Sender: TObject);
    procedure btAbreClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tabSQLTracerContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    const TempFileName: string = 'TempSqlApp345345.sql';
  private
    { Private declarations }

    lista_qy : TStringList;
    procedure antesExecuta(qy : TSQLQuery; instrucao: string);
    procedure executa(qy : TSQLQuery; abre : boolean);
    procedure depoisExecuta(qy : TSQLQuery);
    procedure LoadOldSQLInstructinos;
    procedure MudaGrade(index : Integer);
    procedure destroiConsulta;
  public
    { Public declarations }
    class procedure Open;
    procedure LogTConnectionSQL(AText: string);
  end;

var
  DevToolsForm: TDevToolsForm;

implementation

uses application_functions, db_context;

{$R *.lfm}

{ TDevToolsForm }

class procedure TDevToolsForm.Open;
begin
  with DevToolsForm do
  begin
    gAppDbContext.LogTConnectionDelegate := LogTConnectionSQL;
    lista_qy := TStringList.Create;
    pageTools.ActivePageIndex := 0;
    LoadOldSQLInstructinos;
    ShowModal;
  end;
end;

procedure TDevToolsForm.LogTConnectionSQL(AText: string);
begin
  if ckEnableTracer.Checked  then
  begin
    memoLogTConnection.Lines.Append('---------------------------------------------------------');
    memoLogTConnection.Lines.Append(AText);
  end;
end;

procedure TDevToolsForm.antesExecuta(qy : TSQLQuery; instrucao: string);
begin
  qy.Close;
  qy.SQL.Clear;
  qy.SQL.Add(instrucao);
  edResult.Lines.Add('---');
  edResult.Lines.Add(instrucao);
end;

procedure TDevToolsForm.btExecClick(Sender: TObject);
label 1, 2, 3, 4, 5;

var list, instrucao : TStringList;
    s, iteracao : string;
    i, onde : integer;
    blocoComentado : boolean;
    ds : TDataSource;
    qy : TSQLQuery;

  procedure AddInstrucao;
  begin
    if not (Trim(s) = '') then
    begin
      list.Add(s);
      s := '';
    end;
  end;

  procedure Fim;
  begin
    if not blocoComentado then
      AddInstrucao;
  end;

  function avancaLinha : boolean;
  begin
    Result := False;
    Inc(i);
    if i > instrucao.Count -1 then
      Fim
    else
    begin
      iteracao := instrucao[i];
      Result := True;
    end;
  end;


begin
  list := TStringList.Create;
  instrucao := TStringList.Create;

  // pega o bloco a ser avaliado
  if Trim(edInstrucao.SelText) = '' then
    instrucao.AddStrings(edInstrucao.Lines)
  else
    instrucao.Add(edInstrucao.SelText);

  // remove todos os comentarios
  i := -1;
  blocoComentado := False;

  1:

  AddInstrucao;
  if not avancaLinha then
    goto 2;

  if not blocoComentado then
  begin
    onde := Pos('--',iteracao);
    if onde <> 0 then
    begin
      s := s + Copy(iteracao,1,onde -1);
      goto 1;
    end;

    onde := Pos('/*',iteracao);
    if onde <> 0 then
    begin
      s := s + Copy(iteracao,1,onde -1);
      blocoComentado := True;
      goto 3;
    end;
    s := s + iteracao;
    goto 1;
  end
  else
  begin
    3:
    onde := Pos('*/',iteracao);
    if onde <> 0 then
    begin
      s := s + Copy(iteracao,onde + 2, Length(iteracao) - onde);
      blocoComentado := False;
    end;
    goto 1;
  end;

  2:

  // separa as instrucoes
  i := -1;
  instrucao.Clear;
  instrucao.AddStrings(list);
  list.Clear;

  4:

  if not avancaLinha then
    goto 5;

  if s <> '' then
    s := s + #13#10;

  if (UpperCase(Trim(iteracao)) = 'GO') then
  begin
    AddInstrucao;
    goto 4;
  end;

  s := s + Trim(iteracao);
  goto 4;

  5:

  for i := 0 to list.Count -1 do
  begin
    if UpperCase(Copy(list[i],1,6)) = 'SELECT' then
    begin
      ds := TDataSource.Create(DevToolsForm);
      lista_qy.AddObject('', ds);
      qy := TSQLQuery.Create(Self);
      qy.Transaction := nil;
      qy.DataBase := gAppDbContext.Connection;
      qy.Options := [sqoAutoCommit, sqoAutoApplyUpdates, sqoKeepOpenOnCommit];
      ds.DataSet := qy;
      antesExecuta(qy,list[i]);
      executa(qy,True);
      depoisExecuta(qy);

      labPos.Caption := 'de ' + InttoStr(lista_qy.Count);
      edConta.OnChange := nil;
      edConta.MaxValue := lista_qy.Count;
      edConta.Value := edConta.MaxValue;
      edConta.OnChange := edContaChange;

      if qy.Active then
        MudaGrade(Trunc(edConta.Value))
      else
        destroiConsulta;

    end
    else
    begin
      antesExecuta(q_so_para_ver_as_props,list[i]);
      executa(q_so_para_ver_as_props,False);
      depoisExecuta(q_so_para_ver_as_props);
    end;
  end;

  list.Free;
  instrucao.Free;
end;

procedure TDevToolsForm.ckEnableTracerChange(Sender: TObject);
begin

end;

procedure TDevToolsForm.depoisExecuta(qy : TSQLQuery);
begin
  if qy.Active then
    edResult.Lines.Add('linhas selecionadas: ' + InttoStr(qy.RecordCount))
  else
    edResult.Lines.Add('linhas afetadas: ' + InttoStr(qy.RowsAffected));
end;

procedure TDevToolsForm.LoadOldSQLInstructinos;
var
  tempDir: string;
begin
  tempDir := GetTempDir(False);
  if FileExists(tempDir + TempFileName) then
    edInstrucao.Lines.LoadFromFile(tempDir + TempFileName);
end;

procedure TDevToolsForm.MudaGrade(index : Integer);
begin
  if index = 0 then
    Grade.DataSource := nil
  else
  begin
    Grade.DataSource := TDataSource(lista_qy.Objects[index - 1]);
  end;

  Grade.AutoAdjustColumns;

  btFechaCon.Enabled := Grade.DataSource <> nil;
  btExport.Enabled   := Grade.DataSource <> nil;

  if btExport.Enabled then
    btExport.Enabled := Grade.DataSource.DataSet.RecordCount > 0;

  btHTML.Enabled := btExport.Enabled;
end;

procedure TDevToolsForm.edContaChange(Sender: TObject);
begin
  MudaGrade(Trunc(edConta.Value));
end;

procedure TDevToolsForm.FormDestroy(Sender: TObject);
begin
  gAppDbContext.LogTConnectionDelegate := nil;
  lista_qy.Free;
  edInstrucao.Lines.SaveToFile(GetTempDir(False) + TempFileName);
end;

procedure TDevToolsForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
    btExecClick(nil);
end;

procedure TDevToolsForm.executa(qy: TSQLQuery; abre : boolean);
var vai : TPoint;

  procedure posiciona;
  begin
    vai.Y := edResult.Lines.Count -1;
    vai.X := 0;
    edResult.CaretPos := vai;
    if pageQueriesResults.ActivePage = tabQuery then pageQueriesResults.ActivePage := tabQueryText;
  end;

begin
  try
    if abre then
    begin
      qy.Open;
      (qy.Transaction as TSQLTransaction).Commit;
    end
    else
    begin
      qy.ExecSQL;
      (qy.Transaction as TSQLTransaction).Commit;
      posiciona;
    end;
  except on e: Exception do
    begin
      edResult.Lines.Add('ERRO: ' + e.Message);
      posiciona;
    end;
  end;
end;

procedure TDevToolsForm.destroiConsulta;
var aux : Integer;
begin
  aux := Trunc(edConta.Value) -1;
  if aux = -1 then
    Exit;

  MudaGrade(aux);
  edConta.Value := aux;
  TDataSource(lista_qy.Objects[aux]).DataSet.Free;
  TDataSource(lista_qy.Objects[aux]).Free;
  lista_qy.Delete(aux);
  labPos.Caption := 'de ' + InttoStr(lista_qy.Count);
  edConta.MaxValue := lista_qy.Count;
end;

procedure TDevToolsForm.btFechaConClick(Sender: TObject);
begin
  destroiConsulta;
end;

procedure TDevToolsForm.btExportClick(Sender: TObject);
var i, onde : integer;
    arquivo : TStringList;
    s, aux : string;
begin
  Salvar.FileName := '';
  Salvar.DefaultExt := 'sql';
  Salvar.Filter := '*.sql';
  if Salvar.Execute then
  begin
    
    s := TSQLQuery(Grade.DataSource.DataSet).SQL.Text;
    onde := Pos('from ',s);
    if onde = 0 then
      Exit;

    onde := 1;
    while onde <> 0 do
    begin
      onde := pos(#13#10,s);
      if onde <> 0 then
      begin
        Delete(s,onde,2);
        Insert(' ',s,onde);
      end;
    end;

    onde := pos('from ',s);

    aux := '';
    for i := onde to length(s) - 5 do
    begin
      if (s[i + 5] <> ' ') then
        aux := aux + s[i + 5]
      else
        break;
    end;

    arquivo := TStringList.Create;

    Grade.DataSource.DataSet.DisableControls;
    Grade.DataSource.DataSet.First;
    while not Grade.DataSource.DataSet.Eof do
    begin
      s := 'insert into ' + aux + ' (';

      for i := 0 to Grade.DataSource.DataSet.Fields.Count -1 do
      begin
        s := s + Grade.DataSource.DataSet.Fields[i].Name + ', ';
        //ShowMessage(Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName);
      end;

      Delete(s,Length(s) -1,2);
      s := s + ') values (';


      for i := 0 to Grade.DataSource.DataSet.Fields.Count -1 do
      begin
        {if Grade.DataSource.DataSet.Fields[i].IsNull then
          s := s + 'NULL, '
        else if ((Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassParent.ClassName = 'TNumericField') or
            (Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassParent.ClassParent.ClassName = 'TNumericField')) then
          s := s + NumeroSQL(Grade.DataSource.DataSet.Fields[i].AsFloat) + ', '
        else if ((Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName = 'TStringField') or
                 (Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName = 'TStringField')) then
          s := s + QuotedStr(Grade.DataSource.DataSet.Fields[i].AsString) + ', '
        else if Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName = 'TBooleanField' then
          s := s + BooSQL(Grade.DataSource.DataSet.Fields[i].AsBoolean) + ', '
        else if ((Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName = 'TDateField') or
                 (Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName = 'TDateTimeField')) then
          s := s + DataSQL(Grade.DataSource.DataSet.Fields[i].AsString) + ', '
        else if Grade.DataSource.DataSet.Fields[i].FieldDef.FieldClass.ClassName = 'TMemoField' then
          s := s + QuotedStr(Grade.DataSource.DataSet.Fields[i].AsString) + ', ';
         }
      end;
      Delete(s,Length(s) -1,2);
      s := s + ')';
      arquivo.Add(s);
      arquivo.Add('go');
      Grade.DataSource.DataSet.Next;
    end;
    Grade.DataSource.DataSet.EnableControls;
    
    arquivo.SaveToFile(Salvar.FileName);
    arquivo.Free;
  end;
end;

procedure TDevToolsForm.btHTMLClick(Sender: TObject);

  function vazio(s: string) : string;
  begin
    if s = '' then
      Result := '&nbsp;'
    else
      Result := s;
  end;

var
  i, j, w: integer;
  linha: string;
  arquivo : TStringList;
begin
  Salvar.FileName := '';
  Salvar.DefaultExt := 'html';
  Salvar.Filter := '*.html';
  if Salvar.Execute then
  begin
    arquivo := TStringList.Create;
    arquivo.Add('<html><head><title>' + Salvar.FileName + '</title></head><body bgcolor="#FFFBCB">');
    arquivo.Add('<style type="text/css"> td.a {border: orange solid; border-width: 1px 0px 0px 1px;}');
    arquivo.Add('td.b {border: orange solid; border-width: 1px 1px 0px 1px;}');
    arquivo.Add('td.c {border: orange solid; border-width: 1px 0px 1px 1px;}');
    arquivo.Add('td.d {border: orange solid; border-width: 1px 1px 1px 1px;}</style>');
    arquivo.Add('<table cellspacing="0">');
    with Grade.DataSource.DataSet do
    begin
      DisableControls;
      for w := 0 to FieldCount -1 do
        arquivo.Add('<th>' + (Fields[w].FieldName) + '</th>');

      First;

      // a ultima linha faz sepada para simplificar o if e tornar o sistema mais rápido
      for i := 1 to RecordCount -1 do
      begin
        linha := '<tr>';
        for j := 0 to FieldCount -1 do
          if j < FieldCount -1 then
            linha := linha + '<td class="a">' + vazio(Fields[j].AsString) + '</td>'
          else
            linha := linha + '<td class="b">' + vazio(Fields[j].AsString) + '</td>';

        arquivo.Add(linha + '</tr>');
        Next;
      end;

      // faz a última linha;
      Next;
      linha := '<tr>';
      for j := 0 to FieldCount -1 do
        if j < FieldCount -1 then
          linha := linha + '<td class="c">' + vazio(Fields[j].AsString) + '</td>'
        else
          linha := linha + '<td class="d">' + vazio(Fields[j].AsString) + '</td>';

      arquivo.Add(linha + '</tr></table></body></html>');
      //
      EnableControls;
      arquivo.SaveToFile(Salvar.FileName);
      arquivo.Free;
    end;
  end;

end;

procedure TDevToolsForm.btLimpaClick(Sender: TObject);
begin
  edInstrucao.Clear;
end;

procedure TDevToolsForm.btSalvaClick(Sender: TObject);
begin
  Salvar.DefaultExt := 'sql';
  Salvar.Filter := '*.sql';
  Salvar.FileName := '';
  if Salvar.Execute then
    edInstrucao.Lines.SaveToFile(Salvar.FileName);
end;

procedure TDevToolsForm.btAbreClick(Sender: TObject);
begin
  if Abrir.Execute then
    edInstrucao.Lines.LoadFromFile(Abrir.FileName);
end;

procedure TDevToolsForm.FormShow(Sender: TObject);
begin
  edInstrucao.SetFocus;
end;

procedure TDevToolsForm.tabSQLTracerContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

end.
