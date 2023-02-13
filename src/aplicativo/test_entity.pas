unit test_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm;

type

  { TTestEntity }

  // essa classe foi criada com o propósito único
  // de executar testes nos códigos como dal_base, mini_orm, etc.
  TTestEntity = class(TEntityBase)
    private
      FDateTime: TDateTime;
      FDateTimeNullIfZero: TDateTime;
      FDecimal: Double;
      FInt32: Integer;
      FInt32NullIfZero: Integer;
      FStr: string;
      FStrNullIfEmpty: string;
    public
      class procedure Map;
    published
      property Int32: Integer read FInt32 write FInt32;
      property Int32NullIfZero: Integer read FInt32NullIfZero write FInt32NullIfZero;
      property DateTime: TDateTime read FDateTime write FDateTime;
      property DateTimeNullIfZero: TDateTime read FDateTimeNullIfZero write FDateTimeNullIfZero;
      property Str: string read FStr write FStr;
      property StrNullIfEmpty: string read FStrNullIfEmpty write FStrNullIfEmpty;
      property Decimal: Double read FDecimal write FDecimal;
  end;


implementation


{ TTestEntity }

class procedure TTestEntity.Map;
begin
  TORMMapBuilder.Create.MapModel(TTestEntity, 'TEST')
    .MapInt32PK('ID', 'Id')
    .MapString('SITUACAO', 'Situacao', 4, False)
    .MapInt32('NRO_REVISAO', 'NroRevisao', False)
    .MapInt32('INT_32', 'Int32', False)
    .MapInt32('INT_32_NULL_IF_ZERO', 'Int32NullIfZero', True)
    .MapDateTime('DATE_TIME', 'DateTime', False)
    .MapDateTime('DATE_TIME_NULL_IF_ZERO', 'DateTimeNullIfZero', True)
    .MapString('STR', 'Str', 60, False)
    .MapString('STR_NULL_IF_ZERO', 'StrNullIfEmpty', 60, True)
    .MapDecimal('NUMERO_DECIMAL', 'Decimal', 18, 7);
end;

end.

