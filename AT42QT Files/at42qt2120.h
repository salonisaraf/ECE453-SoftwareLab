#ifndef __AT42QT2120_H__
#define __AT42QT2120_H__

#include "mbed.h"

#define AT42QT2120_SLAVE_ADDR                     (0x1C << 1)

#define AT42QT2120_CHIP_ID_REG                    0
#define AT42QT2120_KEY_STATUS_LO_REG              3
#define AT42QT2120_KEY_STATUS_HI_REG              4

class AT42QT2120 {
  I2C i2c_;
  
  public:
  
  // Read Functions
  AT42QT2120(PinName SCK, PinName SDA);
  uint8_t read_reg(uint8_t reg);
  uint8_t read_chip_id(void);
  uint8_t read_key_status_lo(void);
  uint8_t read_key_status_hi(void);
  
  // Write Functions
  void write_reg(uint8_t reg, uint8_t value);  
  
}; // End Class
#endif
