unit entity_log_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, mini_orm, StrUtils;

type

  { TEntityLogForm }

  TEntityLogForm = class(TForm)
    Ds: TDataSource;
    qLog: TSQLQuery;
    ScrollBox1: TScrollBox;
    Shape1: TShape;
  private
    type
      TSituacao = (Ativo, Inativo);
    procedure OpenLogData(Entity: TORMEntity; Id: Integer);
    procedure GetCriacaoData(Entity: TORMEntity; Id: Integer; var LinhaDeTexto: string);
    procedure GetMudancasSituacao(Entity: TORMEntity; Id: Integer; var StrList: TStringList);
  public
    class procedure Open(EntityClassName: string; Id: Integer);
  end;

var
  EntityLogForm: TEntityLogForm;

implementation

uses db_context;

{$R *.lfm}

{ TEntityLogForm }

procedure TEntityLogForm.OpenLogData(Entity: TORMEntity; Id: Integer);
const pixels = 18;
var
  lastLab, revLabel, labColName: TLabel;
  qtdLines: Integer;
  dataHora: TDateTime;

  procedure GenerateLabel(mustBreakLine: Boolean);
  begin
    lastLab := TLabel.Create(Self);
    lastLab.Left := Shape1.Left + 5;
    lastLab.Top := Shape1.Top + qtdLines * pixels;
    lastLab.AutoSize := True;
    lastLab.WordWrap := False;
    lastLab.Parent := ScrollBox1;
    if mustBreakLine then
      Inc(qtdLines);

    Shape1.Height := lastLab.Top + lastLab.Height;
  end;

  procedure PrintSummary;
  var
    LinhaDeTexto: string;
    StrLinhas: TStringList;
    i: Integer;
  begin
    GenerateLabel(True);
    lastLab.Font.Name := 'Courier New';
    lastLab.Caption := '----- Resumo -----';

    GenerateLabel(True);
    lastLab.Font.Name := 'Courier New';
    GetCriacaoData(Entity, Id, LinhaDeTexto);
    lastLab.Caption := LinhaDeTexto;

    StrLinhas := TStringList.Create;
    GetMudancasSituacao(Entity, Id, StrLinhas);

    for i := 0 to StrLinhas.Count -1 do
    begin
      GenerateLabel(True);
      lastLab.Font.Name := 'Courier New';
      lastLab.Caption := StrLinhas[i];
    end;

    StrLinhas.Free;

    GenerateLabel(True);
    lastLab.Font.Name := 'Courier New';
    lastLab.Caption := '--- Fim Resumo ---';
    Inc(qtdLines);
  end;

  procedure PrintHead;
  begin
    if dataHora <> qLog.FieldByName('data_hora').AsDateTime then
    begin

      // faz pular uma linha para o próximo grupo
      if qtdLines > 0 then
        Inc(qtdLines);

      dataHora := qLog.FieldByName('data_hora').AsDateTime;

      GenerateLabel(True);
      lastLab.Caption := qLog.FieldByName('data_hora').AsString + ', por: [ID] ' + qLog.FieldByName('ID_USUARIO').AsString + ' - ' + qLog.FieldByName('nome').AsString;
      lastLab.Font.Style := [fsBold];

      GenerateLabel(True);
      revLabel := lastLab; // armazena o label que será o de revisão
      lastLab.Font.Style := [fsBold];
    end;
  end;

  procedure PrintRev(Nro, Tipo: string);
  begin
    revLabel.Caption := 'Revisão: ' + Nro + ' - Tipo: ' + Tipo;
  end;

begin
  qLog.SQL.Text :=
    'select l.operacao, l.nome_coluna, l.valor_novo, l.valor_anterior, ' +
    'l.data_hora, l.id_usuario, u.nome from ' + entity.DBTableName + '_LOG l ' +
    'left join usuario u on l.id_usuario = u.id ' +
    'where l.id_pk = :id order by l.data_hora desc';
  qLog.ParamByName('id').Value := Id;
  qLog.Open;

  qtdLines := 0;
  dataHora := 0;

  PrintSummary;

  while not qLog.Eof do
  begin
    PrintHead;

    if qLog.FieldByName('Operacao').AsString = 'I' then
      PrintRev('1', 'Insersão')
    else if qLog.FieldByName('nome_coluna').AsString = 'NRO_REVISAO' then
      PrintRev(qLog.FieldByName('valor_novo').AsString,
        IfThen(qLog.FieldByName('Operacao').AsString = 'U','Atualização', 'Exclusão'))
    else
    begin
      GenerateLabel(False);
      labColName := lastLab;
      labColName.AutoSize := False;
      labColName.Width := 103;
      labColName.Caption := qLog.FieldByName('nome_coluna').AsString + ':';
      labColName.Alignment := taRightJustify;
      //labColName.AdjustSize;

      GenerateLabel(True);
      lastLab.Font.Color := clRed;
      lastLab.Left := 120; //labColName.Left + labColName.Width + 7;
      lastLab.Caption := qLog.FieldByName('valor_anterior').AsString + ' (-)';

      GenerateLabel(True);
      lastLab.Font.Color := clBlue;
      lastLab.Left := 120; //labColName.Left + labColName.Width + 7;
      lastLab.Caption := qLog.FieldByName('valor_novo').AsString + ' (+)';

      //Inc(qtdLines);
    end;

    qLog.Next;
  end;

  qLog.Close;
end;

procedure TEntityLogForm.GetCriacaoData(Entity: TORMEntity; Id: Integer;
  var LinhaDeTexto: string);
var
  q: TSQLQuery;
begin
  q := gAppDbContext.CreateSQLQuery;
  q.SQL.Text :=
    'select l.data_hora, l.id_usuario, u.nome from' + LineEnding +
    Entity.DBTableName + '_LOG l' + LineEnding +
    'left join usuario u on l.id_usuario = u.id' + LineEnding +
    'where l.operacao = ''I'' and id_pk = :id_pk';

  q.ParamByName('id_pk').Value := Id;
  //InputBox('', '', q.SQL.Text);
  q.Open;

  LinhaDeTexto := 'Criado em: ' + DateTimeToStr(q.FieldByName('data_hora').AsDateTime) +
    ' por: [' + q.FieldByName('id_usuario').AsString + '] ' +  q.FieldByName('nome').AsString;

  q.Close;
  q.Free;
end;

procedure TEntityLogForm.GetMudancasSituacao(Entity: TORMEntity; Id: Integer;
  var StrList: TStringList);
var
  q: TSQLQuery;
begin
  q := gAppDbContext.CreateSQLQuery;
  q.SQL.Text :=
    'with cte as' + LineEnding +
    '(' + LineEnding +
    '	    select max(pl.data_hora) data_hora , pl.valor_novo from ' +
    Entity.DBTableName + '_log pl' + LineEnding +
    '	    where pl.operacao = ''U'' and upper(pl.nome_coluna) = ''SITUACAO'' and pl.id_pk = :id_pk' + LineEnding +
    '	    group by pl.valor_novo' + LineEnding +
    ')' + LineEnding +
    'select x.data_hora, x.id_usuario, x.nome_coluna, x.valor_anterior, x.valor_novo, u.nome from cte' + LineEnding +
    'join ' + Entity.DBTableName + '_log x on cte.data_hora = x.data_hora and cte.valor_novo = x.valor_novo' + LineEnding +
    'left join usuario u on x.id_usuario = u.id' + LineEnding +
    'where x.operacao = ''U'' and upper(x.nome_coluna) = ''SITUACAO'' and x.id_pk = :id_pk' + LineEnding +
    'order by x.data_hora';

  q.ParamByName('id_pk').Value := Id;
  q.Open;

  while not q.EOF do
  begin
    StrList.Add('       em: ' + DateTimeToStr(q.FieldByName('data_hora').AsDateTime) +
      ' : SITUACAO ' + q.FieldByName('valor_anterior').AsString +
      ' -> ' + q.FieldByName('valor_novo').AsString +
      ' por: [' + q.FieldByName('id_usuario').AsString + '] ' +  q.FieldByName('nome').AsString);
    q.Next;
  end;

  q.Close;
  q.Free;
end;

class procedure TEntityLogForm.Open(EntityClassName: string; Id: Integer);
var
  entity: TORMEntity;
begin
  Application.CreateForm(TEntityLogForm, EntityLogForm);
  with EntityLogform do
  begin
    entity := TORM.FindORMEntity(EntityClassName);
    qLog.DataBase := gAppDbContext.Connection;
    OpenLogData(entity, Id);

    ShowModal;

    Free;
  end;
end;

end.

