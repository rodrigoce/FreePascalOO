unit entity_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, TypInfo, Variants, validatable, LazUTF8;

type

  { EMaxLengthExceded }

  EMaxLengthExceded = class(Exception);

  { TEntityBase }

  TEntityBase = class(TValidatable)
    private
      FId: Integer;
      FNullFields: TStringList;
      FSituacao: string;
      FNroRevisao: Integer;
      FOldVersion: TEntityBase;
    public
      // ao carregar do banco de dados, faz uma copia da entidade para ser considerada os valores não alterados
      property OldVersion: TEntityBase read FOldVersion write FOldVersion;

      function AsString: string;

      constructor Create;
      destructor Destroy; override;

      // gera uma exception caso os campos strings tenham mais que o length mapeado
      procedure ValidateStringMaxLength;

    published
      property Id: Integer read FId write FId;
      // gravar (A)TIVO (I)NATIVO (E)XCLUIDO
      property Situacao: string read FSituacao write FSituacao;
      // propriedade alimnetada automaticamente em TDALBase.
      property NroRevisao: Integer read FNroRevisao write FNroRevisao;
      //
      property NullFields: TStringList read FNullFields write FNullFields;
  end;

implementation

uses mini_orm;

{ TEntityBase }

procedure TEntityBase.ValidateStringMaxLength;
var
  ormEntity: TORMEntity;
  ormField: TORMField;
  v: string;
begin
  ormEntity := TORM.FindORMEntity(Self.ClassName);

  for ormField in ormEntity.FieldList do
  begin
    if ormField.IsString then
    begin
      v := GetPropValue(Self, ormField.PPropInfo);
      if UTF8Length(v) > ormField.Length then
      begin
          raise EMaxLengthExceded.Create('A propriedade ' + ormField.EntityPropName + ' tem mais de ' + ormField.Length.ToString + ' caracteres no objeto do tipo ' + ormEntity.EntityClassName);
      end;
    end;
  end;
end;

function TEntityBase.AsString: string;
var
  i: Integer;
  vpTypeInfo: PTypeInfo;
  vPTypeData: PTypeData;
  vPPropList: PPropList;
begin

  vpTypeInfo := PTypeInfo(Self.ClassType.ClassInfo);
  vPTypeData := GetTypeData(vpTypeInfo);

  GetPropList(Self, vPPropList);

  Result := '';
  for i := 0 to vPTypeData^.PropCount -1 do
  begin
    Result := Result + vPPropList^[i]^.Name + ': ';
    Result := Result + vPPropList^[i]^.PropType^.Name + ' -> ';
    Result := Result + VarToStr(GetPropValue(Self, vPPropList^[i])) + LineEnding;
  end;
end;

constructor TEntityBase.Create;
begin
  inherited;
  FNullFields := TStringList.Create;
end;

destructor TEntityBase.Destroy;
begin
  if OldVersion <> nil then
    OldVersion.Free;

  FNullFields.Free;

  inherited;
end;

end.

