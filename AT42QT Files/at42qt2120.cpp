#include "at42qt2120.h"
#include "mbed.h"

AT42QT2120::AT42QT2120(PinName SCK, PinName SDA)
: i2c_(SDA, SCK) // set up the pins used for the I2C bus
{
    
}

// Read Functions
uint8_t AT42QT2120::read_reg(uint8_t reg)
{
    char cmd[1] = {reg};
    char data;    
    i2c_.write(AT42QT2120_SLAVE_ADDR, cmd, 1);
    i2c_.read(AT42QT2120_SLAVE_ADDR, &data, 1);
    return data;
}

uint8_t AT42QT2120::read_chip_id(void)
{
    return read_reg(AT42QT2120_CHIP_ID_REG);
}

uint8_t AT42QT2120::read_key_status_lo(void)
{
    return read_reg(AT42QT2120_KEY_STATUS_LO_REG);
}
    
uint8_t AT42QT2120::read_key_status_hi(void)
{
    return read_reg(AT42QT2120_KEY_STATUS_HI_REG);  
}

// Write Functions
void AT42QT2120::write_reg(uint8_t reg, uint8_t value)
{
    char cmd[2] = {reg, value};
    i2c_.write(AT42QT2120_SLAVE_ADDR, cmd, 2);   
}