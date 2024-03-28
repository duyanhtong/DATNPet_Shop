export default class BaseController {
  protected data(data: any) {
    return {
      success: 1,
      data: data,
    };
  }

  protected success() {
    return {
      success: 1,
      data: {},
    };
  }

  protected fail(error: any) {
    return {
      success: 0,
      data: error,
    };
  }

  protected response(response: any) {
    return response;
  }
}
