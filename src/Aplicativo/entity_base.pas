unit entity_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, TypInfo, Variants, validatable, LazUTF8;

type
  { TEntityBase }

  TEntityBase = class(TValidatable)
    private
      FId: LongInt;
      FDataCriacao: TDateTime;
      FDataAtualizacao: TDateTime;
      FDataExclusao: TDateTime;
      FIdUserCriacao: LongInt;
      FIdUserAtualizacao: LongInt;
      FIdUserExclusao: LongInt;
      FOldVersion: TEntityBase;
    public
      // ao carregar do banco de dados, faz uma copia da entidade para ser considerada os valores não alterados
      property OldVersion: TEntityBase read FOldVersion write FOldVersion;

      function AsString: string;

      constructor Create;
      destructor Destroy; override;

      // gera uma exception caso os campos strings tenham mais que o length mapeado
      procedure ValidateStringMaxLength(RaiseError: Boolean = False);

    published
      property Id: LongInt read FId write FId;
      // propriedade alimnetada automaticamente em TDALBase
      property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;
      // propriedade alimnetada automaticamente em TDALBase
      property DataAtualizacao: TDateTime read FDataAtualizacao write FDataAtualizacao;
      // propriedade alimnetada automaticamente em TDALBase
      property DataExclusao: TDateTime read FDataExclusao write FDataExclusao;
      // propriedade alimnetada automaticamente em TDALBase
      property IdUserCriacao: LongInt read FIdUserCriacao write FIdUserCriacao;
      // propriedade alimnetada automaticamente em TDALBase
      property IdUserAtualizacao: LongInt read FIdUserAtualizacao write FIdUserAtualizacao;
      // propriedade alimnetada automaticamente em TDALBase
      property IdUserExclusao: LongInt read FIdUserExclusao write FIdUserExclusao;

  end;

implementation

uses mini_orm;

{ TEntityBase }

procedure TEntityBase.ValidateStringMaxLength(RaiseError: Boolean = False);
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
        Self.AddErrorValidationMsg(ormField.EntityFieldName, 'O campo %s deve ter no máximo ' + ormField.Length.ToString + ' caracteres');

        if RaiseError then
          raise Exception.Create('A propriedade ' + ormField.EntityFieldName + ' tem mais de ' + ormField.Length.ToString + ' caracteres no objeto do tipo ' + ormEntity.EntityClassName);
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

end;

destructor TEntityBase.Destroy;
begin
  if OldVersion <> nil then
    OldVersion.Free;

  inherited;
end;

end.

