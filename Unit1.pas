unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uLkJSON, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.Grids,
  IdServerIOHandler, IdSSL, IdSSLOpenSSL, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, IdAntiFreezeBase, IdAntiFreeze;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Grid: TStringGrid;
    btnGet: TButton;
    btnPost: TButton;
    Label2: TLabel;
    edtStatus: TEdit;
    procedure btnPostClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
  private
    { Private declarations }
    procedure baca_json_post;
    procedure buattabel_post;
    procedure buattabel_get;
    procedure baca_json_get;
    procedure reset_grid;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  urlnya : string;
  js : TlkJSONobject;
  js_pesan : TlkJSONobject;
  postRequest : TStringList;
  hasil: string;
  i : integer;

implementation

{$R *.dfm}

procedure TForm1.btnGetClick(Sender: TObject);
begin
  reset_grid;
  buattabel_get;
  baca_json_get;
end;

procedure TForm1.btnPostClick(Sender: TObject);
begin
  reset_grid;
  buattabel_post;
  baca_json_post;
end;

procedure TForm1.reset_grid;
var
  I: Integer;
begin
  for I := 0 to Grid.ColCount - 1 do
    Grid.Cols[I].Clear;
  Grid.RowCount := 1;
end;

procedure TForm1.buattabel_post;
begin
  with Grid do begin
    RowCount := 2;
    ColCount := 7;
    FixedCols := 1;
    FixedRows := 1;
    ScrollBars := ssBoth;

    Cells[0,0]:='No.';
    Cells[1,0]:='ID';
    Cells[2,0]:='Nama Lengkap';
    Cells[3,0]:='Nama Panggilan';
    Cells[4,0]:='Jenis Kelamin';
    Cells[5,0]:='Alamat';
    Cells[6,0]:='Kota';

    ColWidths[0]:=30;
    ColWidths[1]:=80;
    ColWidths[2]:=200;
    ColWidths[3]:=150;
    ColWidths[4]:=200;
    ColWidths[5]:=200;
    ColWidths[6]:=200;
  end;
end;

procedure TForm1.buattabel_get;
begin
  with Grid do begin
    RowCount := 2;
    ColCount := 4;
    FixedCols := 1;
    FixedRows := 1;
    ScrollBars := ssBoth;

    Cells[0,0]:='No.';
    Cells[1,0]:='Nama';
    Cells[2,0]:='Negara';
    Cells[3,0]:='Kota';

    ColWidths[0]:=30;
    ColWidths[1]:=250;
    ColWidths[2]:=200;
    ColWidths[3]:=200;
  end;
end;

function hubungkan_post(var urlnya : string; isi_request_post : TStringList; kontentipe : string) : string;
var
  hasil_fungsi : string;
  koneksi : TIdHTTP;
  IOHendelnya : TIdSSLIOHandlerSocketOpenSSL;
  AntiHeng : TIdAntiFreeze;
begin
  try
    koneksi := TIdHTTP.Create(nil);

    //Konek Ke HTTPS
    IOHendelnya := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    IOHendelnya.SSLOptions.SSLVersions:=[sslvTLSv1_1,sslvTLSv1_2];
    //Konek Ke HTTPS

    //Anti Heng
    AntiHeng := TIdAntiFreeze.Create(nil);
    AntiHeng.IdleTimeOut:=500;
    AntiHeng.OnlyWhenIdle:=True;
    AntiHeng.Active:=True;
    //Anti Heng

    with koneksi do begin
      HTTPOptions := [hoForceEncodeParams];
      Request.ContentType := kontentipe;
      HandleRedirects := true;
      hasil_fungsi := Post(urlnya,isi_request_post);
      ProtocolVersion := pv1_1;
    end;
    koneksi.Free;
    IOHendelnya.Free;
    AntiHeng.Active:=False;
    AntiHeng.Free;
  except on E: Exception do
    hasil_fungsi := 'error';
  end;

  Result := hasil_fungsi;
end;

function hubungkan_get(var urlnya : string; kontentipe : string) : string;
var
  hasil_fungsi : string;
  koneksi : TIdHTTP;
  IOHendelnya : TIdIOHandler;
begin
  try
    koneksi := TIdHTTP.Create(nil);
    with koneksi do begin
      HTTPOptions := [hoForceEncodeParams];
      Request.ContentType := kontentipe;
      HandleRedirects := true;
      hasil_fungsi := get(urlnya);
    end;
  except on E: Exception do
    hasil_fungsi := 'error';
  end;

  Result := hasil_fungsi;
end;

procedure TForm1.baca_json_post;
begin
  urlnya := 'https://mediasoftsolusindo.com/api_belajar.php?modul=tampil_api_belajar';
  postRequest := TStringList.Create;
  postRequest.Add('pengguna=Riko');
  postRequest.Add('sandi=riko_software');
  Memo1.Lines.Clear;
  try
    hasil := hubungkan_post(urlnya,postRequest,'application/x-www-form-urlencoded');
    Memo1.Lines.Add(hasil);

    js := TlkJSON.ParseText(hasil) as TlkJSONObject;

    js:= TlkJSONObject(js.Field['data']);

    //Sesuaikan julmlah baris Grid dengan banyaknya data dari databasenya
    Grid.RowCount := js.Count + 1;

    //Meload data ke Grid
    for i := 0 to js.Count - 1 do begin
      //Load Data Ke Grid
      Grid.Cells[0,i+1] := IntToStr(i+1)+'.';
      Grid.Cells[1, i + 1] := VarToStr(js.Child[i].Field['idku'].Value);
      Grid.Cells[2, i + 1] := VarToStr(js.Child[i].Field['nama_lengkap'].Value);
      Grid.Cells[3, i + 1] := VarToStr(js.Child[i].Field['nama_panggilan'].Value);
      Grid.Cells[4, i + 1] := VarToStr(js.Child[i].Field['jenis_kelamin'].Value);
      Grid.Cells[5, i + 1] := VarToStr(js.Child[i].Field['alamat'].Value);
      Grid.Cells[6, i + 1] := VarToStr(js.Child[i].Field['kota'].Value);
    end;

    js.Free;

    //tampilkan status jsonnya ke edtStatus
    js_pesan := TlkJSON.ParseText(hasil) as TlkJSONObject;
    edtStatus.Text := VarToStr(js_pesan.Field['pesan'].Value);
    js_pesan.Free;
  except on E: Exception do
    Memo1.Lines.Add('Error bro : '#13#10 + E.Message);
  end;
end;

procedure TForm1.baca_json_get;
begin
  urlnya := 'https://www.w3schools.com/angular/customers.php';

  postRequest := TStringList.Create;
  postRequest.Add('pengguna=Riko');
  postRequest.Add('sandi=riko_software');

  Memo1.Lines.Clear;
  try
    hasil := hubungkan_get(urlnya,'application/x-www-form-urlencoded');
    Memo1.Lines.Add(hasil);

    js := TlkJSON.ParseText(hasil) as TlkJSONObject;

    js:= TlkJSONObject(js.Field['records']);

    //Sesuaikan julmlah baris Grid dengan banyaknya data dari databasenya
    Grid.RowCount := js.Count + 1;

    //Meload data ke Grid
    for i := 0 to js.Count - 1 do begin
      //Load Data Ke Grid
      Grid.Cells[0,i+1] := IntToStr(i+1)+'.';
      Grid.Cells[1, i + 1] := VarToStr(js.Child[i].Field['Name'].Value);
      Grid.Cells[2, i + 1] := VarToStr(js.Child[i].Field['City'].Value);
      Grid.Cells[3, i + 1] := VarToStr(js.Child[i].Field['Country'].Value);
    end;

    js.Free;

    //tampilkan status jsonnya ke edtStatus
    edtStatus.Text := 'Tidak Ada Statusnya';
  except on E: Exception do
    Memo1.Lines.Add('Error bro : '#13#10 + E.Message);
  end;
end;

end.
