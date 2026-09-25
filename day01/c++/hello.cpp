#include "efi.hpp"

extern "C" EFI_STATUS EfiMain(
    EFI_HANDLE        ImageHandle,
    EFI_SYSTEM_TABLE  *SystemTable) {
  SystemTable->ConOut->OutputString(SystemTable->ConOut,
                                    (CHAR16 *)L"Hello, World!\n");
  while (1);
  return 0;
}
