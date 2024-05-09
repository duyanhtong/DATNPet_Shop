export enum OrderStatusEnum {
  pending_confirmation = 'Chờ xác nhận',
  waiting_for_delivery = 'Chờ giao hàng',
  ready_to_pick = 'Chờ lấy hàng',
  picking = 'Đang lấy hàng',
  cancel = 'Huỷ đơn hàng',
  money_collect_picking = 'Đang thu tiền người gửi',
  picked = 'Đã lấy hàng',
  storing = 'Hàng đang nằm ở kho',
  transporting = 'Đang luân chuyển hàng',
  sorting = 'Đang phân loại hàng hóa',
  delivering = 'Đang giao hàng',
  money_collect_delivering = 'Nhân viên đang thu tiền người nhận',
  delivered = 'Giao hàng thành công',
  delivery_fail = 'Giao hàng thất bại',
  waiting_to_return = 'Đang đợi trả hàng về cho người gửi',
  return = 'Trả hàng',
  return_transporting = 'Đang luân chuyển hàng trả',
  return_sorting = 'Đang phân loại hàng trả',
  returning = 'Đang hoàn hàng',
  return_fail = 'Hoàn hàng thất bại',
  returned = 'Hoàn hàng thành công',
  exception = 'Đơn hàng ngoại lệ không nằm trong quy trình',
  damage = 'Hàng bị hư hỏng',
  lost = 'Hàng bị mất',
}

// Hàm trả về giá trị của Enum theo key
export function getStatusValueByKey(key: string): string {
  // Kiểm tra xem key có phải là một trong những key của OrderStatusEnum không
  if (key in OrderStatusEnum) {
    // @ts-ignore: TS không nhận diện được key là một phần của OrderStatusEnum ở đây, nhưng chúng ta đã kiểm tra ở trên
    return OrderStatusEnum[key as keyof typeof OrderStatusEnum];
  }
  // Trả về undefined nếu không tìm thấy key
  return key;
}
