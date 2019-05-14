// rf95_client.pde

#include <SPI.h>
#include <RH_RF95.h>
#include<DFRobotHighTemperatureSensor.h>

const float voltageRef = 5.000;       //Set reference voltage,you need test your IOREF voltage. 
//const float voltageRef = 3.300;    
int HighTemperaturePin = A1;	//Setting pin
DFRobotHighTemperature PT100 = DFRobotHighTemperature(voltageRef); //Define an PT100 object
RH_RF95 rf95;
int led = 8;
int state = 0;
int rssimax;
int SoLanNhanRssiTinHieuThap = 0;
uint8_t id[] = "006";
uint8_t idnodecon[30][4];
uint8_t idnodecha[3];
int dem = 0;
int solangui = 0;
int solannhan = 0;
unsigned long time = 0;
unsigned long time1 = 0;
unsigned long time2 = 0;
unsigned long time3 = 0;
unsigned long time4 = 0;
int idgateway;
int bac;
int idcha;
int idnode;
int sonodecon = 1;

void setup()
{
	Serial.begin(9600);
	if (!rf95.init())
		Serial.println("init failed");
	// khoi tao ban dau id
	for (int i = 0; i <= 29; i++)
	{
		for (int j = 0; j <= 3; j++)
		{
			idnodecon[i][j] = '0';
		}
	}
}

void loop()
{
	if (state == 0)
	{
		ketnoi();
	}
	else if (state == 1)
	{
		ketnoimuc1();
	}
	else if (state == 2)
	{
		ketnoimuc2();
	}
	else if (state == 3)
	{
		nodetrunggian();
	}
	else
	{
		Serial.println("the end");
	}
}

void ketnoi()
{
	if (millis() - time1 > 4000)
	{
		time1 = millis();
	}
	else if (millis() - time1 == 4000)
	{
		Serial.println("gui tin hieu yeu cau ket noi voi node cha");
		// Send a message to rf95_server
		uint8_t data[7] = "kn0"; //kn yeu cau ket noi
		data[3] = id[0];
		data[4] = id[1];
		data[5] = id[2];
		rf95.send(data, sizeof(data));
		rf95.waitPacketSent();
		time1 = millis();
	}

	if (rf95.available())
	{
		// Should be a message for us now   
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu nhan duoc: ");
			Serial.println((char*)buf);
			uint8_t *a = (uint8_t*)buf;
			//for (int i = 0; i < 15; i++)
			//{
			//	Serial.print(a[i]);

			//	Serial.print(" ");
			//}
			Serial.println(" ");
			Serial.print("RSSI: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&&a[1] == 't'&&a[2] == '1'&&a[6] == id[0] && a[7] == id[1] && a[8] == id[2]) // ket noi tin hieu muc cao
			{
				Serial.println("thuc hien ket noi muc 1");
				delay(400);
				kt(a);
				state = 1;
			}
			else if (a[0] == 'k'&&a[1] == 't'&&a[2] == '2'&&a[6] == id[0] && a[7] == id[1] && a[8] == id[2])  //ket noi tin hieu muc thap
			{
				Serial.println("thuc hien ket noi muc 2");
				kt(a);
				state = 2;
			}
			else if (a[0] == 'k'&&a[1] == 't'&&a[2] == '3'&&a[6] == id[0] && a[7] == id[1] && a[8] == id[2])  //ket noi tin hieu 
			{
				if (rssi > -30 || SoLanNhanRssiTinHieuThap > 10)
				{
					Serial.println("thuc hien ket noi muc 3");
					kt(a);
					state = 3;
				}
				else {
					SoLanNhanRssiTinHieuThap = SoLanNhanRssiTinHieuThap + 1;
					Serial.print("so lan dem: ");
					Serial.println(SoLanNhanRssiTinHieuThap);
				}
			}
			digitalWrite(led, LOW);
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}

void ketnoimuc1()
{
	if (rf95.available())
	{
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu gui den: ");
			Serial.println((char*)buf);
			uint8_t *a = (uint8_t*)buf;
			Serial.print("RSSI : ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi > -30)
			{
				Serial.println("node con co the ket noi voi tin hieu muc cao");
				uint8_t data[30] = "kt1"; //kt1 la cho ket noi voi cac node co tin hieu muc cao
				kn0(data, a);
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc0(a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc1(a);
			}
			else if (a[0] == 'k'&&a[1] == 't'&&a[2] == '2'&&a[3] == idnodecha[0] && a[4] == idnodecha[1] && a[5] == idnodecha[2])
			{
				state = 2;
				Serial.println("thuc hien ket noi buc 2");
			}
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}

void ketnoimuc2()
{
	if (millis() - time1 > 4000)
	{
		time1 = millis();
	}
	else if (millis() - time1 == 4000)
	{
		Serial.println("gui du lieu yeu cau node con ket noi muc 2");
		uint8_t data[7] = "kt2"; //kt2 la cho ket noi voi cac node co tin hieu muc thap
		data[3] = id[0];
		data[4] = id[1];
		data[5] = id[2];
		rf95.send(data, sizeof(data));
		rf95.waitPacketSent();
		time1 = millis();
	}
	if (rf95.available())
	{
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu gui den: ");
			Serial.println((char*)buf);
			uint8_t *a = (uint8_t*)buf;
			Serial.print("RSSI: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi < -30)
			{
				Serial.println("thuc hien ket noi muc 2");
				Serial.println("node con co the ket noi voi tin hieu muc thap");
				uint8_t data[30] = "kt2"; //kt2 la cho ket noi voi cac node co tin hieu muc thap
				kn0(data, a);
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc0(a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc1(a);
			}
			else if (a[0] == 'k'&& a[1] == 'g'&& a[2] == '0'&&a[3] == idnodecha[0] && a[4] == idnodecha[1] && a[5] == idnodecha[2])
			{
				state = 3;
			}
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}

void nodetrunggian()
{
	if (dem <= 2)
	{
		if (millis() - time3 > 4000)
		{
			time3 = millis();
		}
		else if (millis() - time3 == 4000)
		{
			Serial.println("gui du lieu yeu cau node con gui du lieu");
			// Send a message to rf95_server
			uint8_t data[7] = "kg0"; // kg0 yeu cau node con bat dau gui du lieu len node cha
			data[3] = id[0];
			data[4] = id[1];
			data[5] = id[2];
			rf95.send(data, sizeof(data));
			rf95.waitPacketSent();
			time3 = millis();
			dem = dem + 1;
		}
	}
	///chuong trinh gui du lieu do duoc cua node
	if (millis() - time4 > 10000)
	{
		time4 = millis();
	}
	else if (millis() - time4 == 10000)
	{
		Serial.println("gui du lieu do duoc");
		int temperature = PT100.readTemperature(HighTemperaturePin);  //Get temperature
		char nhietdo[5];
		itoa(temperature, nhietdo, 10);
		Serial.print("temperature1:  ");
		Serial.print(temperature);
		Serial.println("  ^C");
		// Send a message to rf95_server
		uint8_t data[15] = "kg1"; //kg1 thuc hien gui du lieu len node cha
		data[3] = idnodecha[0];   //data[3] -> data[4] dia chi node cha
		data[4] = idnodecha[1];
		data[5] = idnodecha[2];
		data[6] = id[0];          //data[6]->data[8] dia chia node con
		data[7] = id[1];
		data[8] = id[2];
		data[9] = id[0];          //data[9]->data[11] dia chi node gui du lieu ban dau
		data[10] = id[1];
		data[11] = id[2];
//		data[12] = (uint8_t)(temperature);
		data[12] = nhietdo[0];
		data[13] = nhietdo[1];
		Serial.print("data: ");
		Serial.println(sizeof(data));
		Serial.println((char*)data);
		rf95.send(data, sizeof(data));
		rf95.waitPacketSent();
		time4 = millis();
		solangui = solangui + 1;
		Serial.print("so lan gui: ");
		Serial.println(solangui);
	}


	///////////////////////////////////////////////

	/// chuong trinh gui du lieu tu node con

	if (rf95.available())
	{
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu gui den: ");
			Serial.println((char*)buf);
			uint8_t *a = (uint8_t*)buf;
			if (a[0] == 'k'&& a[1] == 'g'&& a[2] == '1')
			{
				Serial.print(a[12]);
				Serial.println(" ^C");
				for (int i = 0; i <= 29; i++)
				{
					if (idnodecon[i][0] == '1')
					{
						if (a[3] == id[0] && a[4] == id[1] && a[5] == id[2] && a[6] == (idnodecon[i][1]) && a[7] == (idnodecon[i][2]) && a[8] == (idnodecon[i][3]))
						{
							uint8_t data[14] = "kg1"; //kg1 thuc hien gui du lieu len node cha
							data[3] = idnodecha[0];
							data[4] = idnodecha[1];
							data[5] = idnodecha[2];
							data[6] = id[0];
							data[7] = id[1];
							data[8] = id[2];
							data[9] = a[9];
							data[10] = a[10];
							data[11] = a[11];
							data[12] = a[12];
							rf95.send(data, sizeof(data));
							rf95.waitPacketSent();
							solangui = solangui + 1;
							Serial.print("so lan gui: ");
							Serial.println(solangui);
							uint8_t data1[10] = "dn1"; //dn1 gui hieu phan roi da nhan cho node con
							data1[3] = id[0];
							data1[4] = id[1];
							data1[5] = id[2];
							data1[6] = a[6];
							data1[7] = a[7];
							data1[8] = a[8];
							rf95.send(data1, sizeof(data1));
							rf95.waitPacketSent();
							i = 101;
						}
					}
				}
			}
			else if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0')
			{
				Serial.println("thuc hien ket noi kn0 ");
				uint8_t data[30] = "kt3"; //kt3 cho ket noi voi cac node 
				kn0(data, a);
				digitalWrite(led, LOW);
				Serial.print("du lieu truyen di: ");
				Serial.println((char*)data);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc0(a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc1(a);
			}
			else if (a[0] == 'd'&& a[1] == 'n'&& a[2] == '1'&&a[3] == idnodecha[0] && a[4] == idnodecha[1] && a[5] == idnodecha[2] && a[6] == id[0] && a[7] == id[1] && a[8] == id[2])
			{
				solannhan = solannhan + 1;
				Serial.print("so lan nhan: ");
				Serial.println(solannhan);
			}


			digitalWrite(led, LOW);
		}
		else
		{
			Serial.println("recv failed");
		}
	}

	if (solangui == 10)
	{

		if (solangui - solannhan < 5)
		{
			solangui = 0;
			solannhan = -1;
		}
		else
		{
			state = 0;
			idnodecha[0] = '0';
			idnodecha[1] = '0';
			idnodecha[2] = '0';
			solangui = 0;
			solannhan = 0;
		}
	}
}

void kt(uint8_t a[])
{
	idnodecha[0] = a[3];
	idnodecha[1] = a[4];
	idnodecha[2] = a[5];
	idgateway = (int)a[9];
	bac = (int)a[10] + 1;
	idcha = (int)a[11];
	idnode = (int)a[12];
	uint8_t data[17] = "tc0"; //tc0  chap nhan ket noi
	data[3] = a[3];
	data[4] = a[4];
	data[5] = a[5];
	data[6] = id[0];
	data[7] = id[1];
	data[8] = id[2];
	data[9] = (uint8_t)idgateway;
	data[10] = (uint8_t)bac;
	data[11] = (uint8_t)idcha;
	data[12] = (uint8_t)idnode;
	data[13] = id[0];
	data[14] = id[1];
	data[15] = id[2];
	rf95.send(data, sizeof(data));
	rf95.waitPacketSent();
	Serial.println((char*) (data));
	Serial.println("Sent kt");
}

void kn0(uint8_t data[], uint8_t a[])
{
	uint8_t data1[14];
	data1[0] = data[0];
	data1[1] = data[1];
	data1[2] = data[2];
	data1[3] = id[0];
	data1[4] = id[1];
	data1[5] = id[2];
	data1[6] = a[3];
	data1[7] = a[4];
	data1[8] = a[5];
	data1[9] = (uint8_t)idgateway;
	data1[10] = (uint8_t)bac;
	data1[11] = (uint8_t)idnode;
	data1[12] = (uint8_t)sonodecon;
	rf95.send(data1, sizeof(data1));
	rf95.waitPacketSent();
	Serial.println("Sent a reply");
}

void tc0(uint8_t a[])
{
	for (int i = 0; i <= 29; i++)
	{
		if (idnodecon[i][0] == '0')
		{
			idnodecon[i][0] = '1';
			idnodecon[i][1] = a[6];
			idnodecon[i][2] = a[7];
			idnodecon[i][3] = a[8];
			Serial.println("luu id node con");
			sonodecon = sonodecon + 1;
			uint8_t data[17] = "tc1";
			data[3] = idnodecha[0];   //data[3] -> data[4] dia chi node cha
			data[4] = idnodecha[1];
			data[5] = idnodecha[2];
			data[6] = id[0];          //data[6]->data[8] dia chia node con
			data[7] = id[1];
			data[8] = id[2];
			for (int i = 9; i <= 15; i++)
			{
				data[i] = a[i];
			}
			rf95.send(data, sizeof(data));
			rf95.waitPacketSent();
			i = 101;
		}
	}
}

void tc1(uint8_t a[])
{
	uint8_t data[17];
	data[0] = a[0];
	data[1] = a[1];
	data[2] = a[2];
	data[3] = idnodecha[0];
	data[4] = idnodecha[1];
	data[5] = idnodecha[2];
	data[6] = id[0];
	data[7] = id[1];
	data[8] = id[2];
	for (int i = 9; i <= 15; i++)
	{
		data[i] = a[i];
	}
	rf95.send(data, sizeof(data));
	rf95.waitPacketSent();
}