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
uint8_t id[] = "004";
uint8_t idnodecon[100][4];
uint8_t idnodecha[3];
int dem = 0;
int solangui = 0;
int solannhan = 0;
unsigned long time = 0;
unsigned long time1 = 0;
unsigned long time2 = 0;
unsigned long time3 = 0;
unsigned long time4 = 0;
void setup()
{
	Serial.begin(9600);
	if (!rf95.init())
		Serial.println("init failed");
	// khoi tao ban dau id
	for (int i = 0; i <= 99; i++)
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



}
void ketnoi()
{
	if (millis() - time1 > 4000)
	{
		time1 = millis();
	}
	else if (millis() - time1 == 4000)
	{
		Serial.println("gui du lieu ket noi");
		// Send a message to rf95_server
		uint8_t data[30] = "kn0"; //kn yeu cau ket noi
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
			if (a[0] == 'k'&&a[1] == 't'&&a[2] == '1'&&a[6] == id[0] && a[7] == id[1] && a[8] == id[2]) // ket noi tin hieu muc cao
			{
				idnodecha[0] = a[3];
				idnodecha[1] = a[4];
				idnodecha[2] = a[5];
				uint8_t data[30] = "tc0"; //tc0  chap nhan ket noi
				data[3] = a[3];
				data[4] = a[4];
				data[5] = a[5];
				data[6] = id[0];
				data[7] = id[1];
				data[8] = id[2];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				state = 1;
			}
			else if (a[0] == 'k'&&a[1] == 't'&&a[2] == '2'&&a[6] == id[0] && a[7] == id[1] && a[8] == id[2])  //ket noi tin hieu muc thap
			{
				idnodecha[0] = a[3];
				idnodecha[1] = a[4];
				idnodecha[2] = a[5];
				uint8_t data[30] = "tc0"; //tc0  chap nhan ket noi
				data[3] = a[3];
				data[4] = a[4];
				data[5] = a[5];
				data[6] = id[0];
				data[7] = id[1];
				data[8] = id[2];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				state = 2;
			}
			else if (a[0] == 'k'&&a[1] == 't'&&a[2] == '3'&&a[6] == id[0] && a[7] == id[1] && a[8] == id[2])  //ket noi tin hieu muc thap
			{
				idnodecha[0] = a[3];
				idnodecha[1] = a[4];
				idnodecha[2] = a[5];
				uint8_t data[30] = "tc0"; //tc0  chap nhan ket noi
				data[3] = a[3];
				data[4] = a[4];
				data[5] = a[5];
				data[6] = id[0];
				data[7] = id[1];
				data[8] = id[2];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				state = 2;
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
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi > -25)
			{
				Serial.println("thuc hien ket noi ");
				uint8_t data[30] = "kt1"; //kt1 la cho ket noi voi cac node co tin hieu muc cao
				data[3] = id[0];
				data[4] = id[1];
				data[5] = id[2];
				data[6] = a[3];
				data[7] = a[4];
				data[8] = a[5];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				Serial.println("Sent a reply");
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '0')
					{
						idnodecon[i][0] = '1';
						idnodecon[i][1] = a[3];
						idnodecon[i][2] = a[4];
						idnodecon[i][3] = a[5];
						i = 101;
						Serial.println("ket noi lan dau");
					}
				}
			}
			//   
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
		Serial.println("gui du lieu ket noi");
		// Send a message to rf95_server
		uint8_t data[30] = "kt2"; //kn yeu cau ket noi
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
			Serial.print("RSSI aa: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi > -30)
			{
				Serial.println("thuc hien ket noi");
				uint8_t data[30] = "kt2"; //kt2 la cho ket noi voi cac node co tin hieu muc thap
				data[3] = id[0];
				data[4] = id[1];
				data[5] = id[2];
				data[6] = a[3];
				data[7] = a[4];
				data[8] = a[5];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				Serial.println("Sent a reply");
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '0')
					{
						idnodecon[i][0] = '1';
						idnodecon[i][1] = a[3];
						idnodecon[i][2] = a[4];
						idnodecon[i][3] = a[5];
						i = 101;
						Serial.println("ket noi lan dau");
					}
				}
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
			Serial.println("gui du lieu ket noi");
			// Send a message to rf95_server
			uint8_t data[30] = "kg0"; // kg0 yeu cau node con bat dau gui du lieu len node cha
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
	if (millis() - time4 > 4000)
	{
		time4 = millis();
	}
	else if (millis() - time4 == 4000)
	{
		Serial.println("gui du lieu ket noi");
		int temperature = PT100.readTemperature(HighTemperaturePin);  //Get temperature
		Serial.print("temperature1:  ");
		Serial.print(temperature);
		Serial.println("  ^C");
		// Send a message to rf95_server
		uint8_t data[30] = "kg1"; //kg1 thuc hien gui du lieu len node cha
		data[3] = idnodecha[0];   //data[3] -> data[4] dia chi node cha
		data[4] = idnodecha[1];
		data[5] = idnodecha[2];
		data[6] = id[0];          //data[6]->data[8] dia chia node con
		data[7] = id[1];
		data[8] = id[2];
		data[9] = id[0];          //data[9]->data[11] dia chi node gui du lieu ban dau
		data[10] = id[1];
		data[11] = id[2];
		data[12] = (uint8_t) temperature;
		Serial.print("data: ");
		Serial.println(sizeof(data));
//		data[13] = '4';
		rf95.send(data, sizeof(data));
		rf95.waitPacketSent();
		time4 = millis();
		solangui = solangui + 1;
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
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '1')
					{
						if (a[3] == id[0] && a[4] == id[1] && a[5] == id[2] && a[6] == (idnodecon[i][1]) && a[7] == (idnodecon[i][2]) && a[8] == (idnodecon[i][3]))
						{
							uint8_t data[30] = "kg1"; //kg1 thuc hien gui du lieu len node cha
							data[3] = idnodecha[0];
							data[4] = idnodecha[1];
							data[5] = idnodecha[2];
							data[6] = id[6];   /// data[6]->data[8] la giu lieu do duoc nhu nhiet do, do am..
							data[7] = id[7];
							data[8] = id[8];
							data[9] = a[9];
							data[10] = a[10];
							data[11] = a[11];
							data[12] = a[12];
							data[13] = a[13];
							rf95.send(data, sizeof(data));
							rf95.waitPacketSent();
							solangui = solangui + 1;
							i = 101;
						}
					}
				}
			}
			else if (a[0] == 'd'&& a[1] == 'n'&& a[2] == '1'&&a[3] == idnodecha[0] && a[4] == idnodecha[1] && a[5] == idnodecha[2] && a[6] == id[0] && a[7] == id[1] && a[8] == id[2])
			{
				solannhan = solannhan + 1;
			}
			digitalWrite(led, LOW);

			if (solangui == 10)
			{
				if (solangui - solannhan > 8)
				{
					solangui = 0;
					solannhan = 0;
				}
				else
				{
					state = 0;
				}
			}
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}