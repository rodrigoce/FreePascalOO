unit query_runner_form;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, sqldb, DBGrids, ComCtrls, Spin, conexao_dm;

type

  { TQueryRunnerForm }

  TQueryRunnerForm = class(TForm)
    q: TSQLQuery;
    SpinEdit1: TSpinEdit;
    Splitter1: TSplitter;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Grade: TDBGrid;
    Panel4: TPanel;
    labPos: TLabel;
    edConta: TSpinEdit;
    btFechaCon: TButton;
    TabSheet2: TTabSheet;
    edResult: TMemo;
    Panel1: TPanel;
    Panel3: TPanel;
    btExec: TButton;
    edInstrucao: TMemo;
    btExport: TButton;
    Salvar: TSaveDialog;
    btHTML: TButton;
    btLimpa: TButton;
    btSalva: TButton;
    btAbre: TButton;
    Abrir: TOpenDialog;
    procedure btExecClick(Sender: TObject);
    procedure edContaChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btFechaConClick(Sender: TObject);
    procedure btExportClick(Sender: TObject);
    procedure btHTMLClick(Sender: TObject);
    procedure btLimpaClick(Sender: TObject);
    procedure btSalvaClick(Sender: TObject);
    procedure btAbreClick(Sender: TObject);
  private
    { Private declarations }
    lista_qy : TStringList;
    procedure antesExecuta(qy : TSQLQuery; instrucao: string);
    procedure executa(qy : TSQLQuery; abre : boolean);
    procedure depoisExecuta(qy : TSQLQuery);
    procedure MudaGrade(index : Integer);
    procedure destroiConsulta;
  public
    { Public declarations }
    class procedure Open;
  end;

var
  QueryRunnerForm: TQueryRunnerForm;

implementation

uses application_functions;

{$R *.lfm}

{ TQueryRunnerForm }

class procedure TQueryRunnerForm.Open;
begin
  with QueryRunnerForm do
  begin
    Application.CreateForm(TQueryRunnerForm, QueryRunnerForm);
    lista_qy := TStringList.Create;
    ShowModal;
    lista_qy.Free;
    Free;
  end;
end;

procedure TQueryRunnerForm.antesExecuta(qy : TSQLQuery; instrucao: string);
begin
  qy.Close;
  qy.SQL.Clear;
  qy.SQL.Add(instrucao);
  edResult.Lines.Add('---');
  edResult.Lines.Add(instrucao);
end;

procedure TQueryRunnerForm.btExecClick(Sender: TObject);
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
      ds := TDataSource.Create(QueryRunnerForm);
      lista_qy.AddObject('',ds);
      qy := TSQLQuery.Create(Self);
      qy.DataBase := ConexaoDM.Conexao;
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
      antesExecuta(q,list[i]);
      executa(q,False);
      depoisExecuta(q);
    end;
  end;

  list.Free;
  instrucao.Free;
end;

procedure TQueryRunnerForm.depoisExecuta(qy : TSQLQuery);
begin
  if qy.Active then
    edResult.Lines.Add('linhas selecionadas: ' + InttoStr(qy.RecordCount))
  else
    edResult.Lines.Add('linhas afetadas: ' + InttoStr(qy.RowsAffected));
end;

procedure TQueryRunnerForm.MudaGrade(index : Integer);
begin
  if index = 0 then
    Grade.DataSource := nil
  else
  begin
    Grade.DataSource := TDataSource(lista_qy.Objects[index - 1]);
  end;

  btFechaCon.Enabled := Grade.DataSource <> nil;
  btExport.Enabled   := Grade.DataSource <> nil;

  if btExport.Enabled then
    btExport.Enabled := Grade.DataSource.DataSet.RecordCount > 0;

  btHTML.Enabled := btExport.Enabled;
end;

procedure TQueryRunnerForm.edContaChange(Sender: TObject);
begin
  MudaGrade(Trunc(edConta.Value));
end;

procedure TQueryRunnerForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
    btExecClick(nil);
end;

procedure TQueryRunnerForm.executa(qy: TSQLQuery; abre : boolean);
var vai : TPoint;

  procedure posiciona;
  begin
    vai.Y := edResult.Lines.Count -1;
    vai.X := 0;
    edResult.CaretPos := vai;
    if PageControl1.ActivePage = TabSheet1 then PageControl1.ActivePage := TabSheet2;
  end;

begin
  try
    if abre then
      qy.Open
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

procedure TQueryRunnerForm.destroiConsulta;
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

procedure TQueryRunnerForm.btFechaConClick(Sender: TObject);
begin
  destroiConsulta;
end;

procedure TQueryRunnerForm.btExportClick(Sender: TObject);
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

procedure TQueryRunnerForm.btHTMLClick(Sender: TObject);

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

procedure TQueryRunnerForm.btLimpaClick(Sender: TObject);
begin
  edInstrucao.Clear;
end;

procedure TQueryRunnerForm.btSalvaClick(Sender: TObject);
begin
  Salvar.DefaultExt := 'sql';
  Salvar.Filter := '*.sql';
  Salvar.FileName := '';
  if Salvar.Execute then
    edInstrucao.Lines.SaveToFile(Salvar.FileName);
end;

procedure TQueryRunnerForm.btAbreClick(Sender: TObject);
begin
  if Abrir.Execute then
    edInstrucao.Lines.LoadFromFile(Abrir.FileName);
end;

end.
