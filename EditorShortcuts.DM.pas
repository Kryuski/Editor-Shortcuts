(* Kryvich's Editor Shortcuts for Delphi IDE.
  Sets keyboard shortcuts to move to a next/prev modification.
  (C) 2018 Aleg Azarouski
*)

unit EditorShortcuts.DM;

interface

uses
  System.SysUtils, System.Classes, ToolsAPI;

type
  TdmEditorShortcuts = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FKeyBindingInd: Integer;
  public
  end;

var
  dmEditorShortcuts: TdmEditorShortcuts;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  UITypes;

{$R *.dfm}

const
//!!  scPrevModification = scCtrl or vkLeftBracket;
//!!  scNextModification = scCtrl or vkRightBracket;
//!!  scPrevModification = scCtrl or vkMinus;
//!!  scNextModification = scCtrl or vkEqual;
  scPrevModification = scShift or scCtrl or vkSubtract;
  scNextModification = scShift or scCtrl or vkAdd;

type
  TKeyboardBinding = class(TNotifierObject, IOTAKeyboardBinding)
  private
    procedure GoToModification(const Context: IOTAKeyContext;
      KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
  public
    procedure BindKeyboard(const BindingServices: IOTAKeyBindingServices);
    function GetBindingType: TBindingType;
    function GetDisplayName: string;
    function GetName: string;
  end;

procedure TdmEditorShortcuts.DataModuleCreate(Sender: TObject);
var
  keyboardServices: IOTAKeyboardServices;
begin
  FKeyBindingInd := -1;
  if BorlandIDEServices = nil then
    Exit;
  if not BorlandIDEServices.GetService(IOTAKeyboardServices, keyboardServices) then
    Exit;
  FKeyBindingInd := keyboardServices.AddKeyboardBinding(TKeyboardBinding.Create);
end;

procedure TdmEditorShortcuts.DataModuleDestroy(Sender: TObject);
begin
  if FKeyBindingInd > -1 then
    (BorlandIDEServices As IOTAKeyboardServices).RemoveKeyboardBinding(FKeyBindingInd);
end;

{ TKeyboardBinding }

procedure TKeyboardBinding.BindKeyboard(
  const BindingServices: IOTAKeyBindingServices);
begin
  BindingServices.AddKeyBinding([scNextModification], GoToModification, nil);
  BindingServices.AddKeyBinding([scPrevModification], GoToModification, nil)
end;

function TKeyboardBinding.GetBindingType: TBindingType;
begin
  Result := btPartial;
end;

function TKeyboardBinding.GetDisplayName: string;
begin
  Result := 'Kryvich''s Editor Binding';
end;

function TKeyboardBinding.GetName: string;
begin
  Result := 'KryvichEditorBinding';
end;

procedure TKeyboardBinding.GoToModification(const Context: IOTAKeyContext;
  KeyCode: TShortcut; var BindingResult: TKeyBindingResult);
var
  editor: IOTAEditBuffer;
  view: IOTAEditView;
  dir: TSearchDirection;
begin
  BindingResult := krHandled;
  editor := Context.EditBuffer;
  if editor = nil then
    Exit;
  view := editor.TopView;
  if view = nil then
    Exit;
  if KeyCode = scPrevModification then
    dir := sdBackward
  else
    dir := sdForward;
  view.NavigateToModification(dir, mtAnyMod);
end;

initialization
  dmEditorShortcuts := TdmEditorShortcuts.Create(nil);
finalization
  dmEditorShortcuts.Free;
end.
