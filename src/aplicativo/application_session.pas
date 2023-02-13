unit application_session;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, usuario_entity, db_context ;

type

  { TApplicationSession }

  TApplicationSession = class
  private
    class procedure InitAppDbcontext;
  public
    class var LogedUser: TUsuarioEntity;
    class procedure InitEnvironment;
    class procedure EndEnvironment;
  end;

implementation

uses dev_tools_form, produto_entity, fornecedor_entity,
  compra_entity, compra_item_entity, test_entity;

{ TApplicationSession }

class procedure TApplicationSession.InitAppDbcontext;
begin
  gAppDbContext := TDBContext.Create;

  TProdutoEntity.Map;
  TUsuarioEntity.Map;
  TFornecedorEntity.Map;
  TCompraEntity.Map;
  TCompraItemEntity.Map;
  TTestEntity.Map;
end;

class procedure TApplicationSession.InitEnvironment;
begin
  DefaultFormatSettings.ThousandSeparator := '.';
  DefaultFormatSettings.DecimalSeparator := ',';
  DefaultFormatSettings.DateSeparator := '/';
  DefaultFormatSettings.CurrencyString := 'R$';
  DefaultFormatSettings.ShortDateFormat := 'dd/mm/yyyy';

  DefaultFormatSettings.ShortMonthNames[1] := 'Jan';
  DefaultFormatSettings.ShortMonthNames[2] := 'Fev';
  DefaultFormatSettings.ShortMonthNames[3] := 'Mar';
  DefaultFormatSettings.ShortMonthNames[4] := 'Abr';
  DefaultFormatSettings.ShortMonthNames[5] := 'Mai';
  DefaultFormatSettings.ShortMonthNames[6] := 'Jun';
  DefaultFormatSettings.ShortMonthNames[7] := 'Jul';
  DefaultFormatSettings.ShortMonthNames[8] := 'Ago';
  DefaultFormatSettings.ShortMonthNames[9] := 'Set';
  DefaultFormatSettings.ShortMonthNames[10] := 'Out';
  DefaultFormatSettings.ShortMonthNames[11] := 'Nov';
  DefaultFormatSettings.ShortMonthNames[12] := 'Dez';

  DefaultFormatSettings.LongMonthNames[1] := 'Janeiro';
  DefaultFormatSettings.LongMonthNames[2] := 'Fevereiro';
  DefaultFormatSettings.LongMonthNames[3] := 'Março';
  DefaultFormatSettings.LongMonthNames[4] := 'Abril';
  DefaultFormatSettings.LongMonthNames[5] := 'Maio';
  DefaultFormatSettings.LongMonthNames[6] := 'Junho';
  DefaultFormatSettings.LongMonthNames[7] := 'Julho';
  DefaultFormatSettings.LongMonthNames[8] := 'Agosto';
  DefaultFormatSettings.LongMonthNames[9] := 'Setembro';
  DefaultFormatSettings.LongMonthNames[10] := 'Outubro';
  DefaultFormatSettings.LongMonthNames[11] := 'Novembro';
  DefaultFormatSettings.LongMonthNames[12] := 'Dezembro';

  DefaultFormatSettings.ShortDayNames[1] := 'Dom';
  DefaultFormatSettings.ShortDayNames[2] := 'Seg';
  DefaultFormatSettings.ShortDayNames[3] := 'Ter';
  DefaultFormatSettings.ShortDayNames[4] := 'Qua';
  DefaultFormatSettings.ShortDayNames[5] := 'Qui';
  DefaultFormatSettings.ShortDayNames[6] := 'Sex';
  DefaultFormatSettings.ShortDayNames[7] := 'Sab';

  DefaultFormatSettings.LongDayNames[1] := 'Domingo';
  DefaultFormatSettings.LongDayNames[2] := 'Segunda-Feira';
  DefaultFormatSettings.LongDayNames[3] := 'Terça-Feira';
  DefaultFormatSettings.LongDayNames[4] := 'Quarta-Feira';
  DefaultFormatSettings.LongDayNames[5] := 'Quinta-Feira';
  DefaultFormatSettings.LongDayNames[6] := 'Sexta-Feira';
  DefaultFormatSettings.LongDayNames[7] := 'Sábado';

  InitAppDbcontext;

  DevToolsForm := TDevToolsForm.Create(nil);
end;

class procedure TApplicationSession.EndEnvironment;
begin
  DevToolsForm.Free;
  gAppDbContext.Free;
end;

end.

