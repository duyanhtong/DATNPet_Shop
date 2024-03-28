import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Category } from './entities/category.entity';
import { Brackets, Repository } from 'typeorm';
import { CreateCategoryDto } from './dtos/create-category.dto';
import {
  ErrorCodeCategory,
  ErrorMessageCategory,
} from './constants/error-code-category.constant';
import { UpdateCategoryDto } from './dtos/update-category.dto';
import { CategoryFilterType } from './interface/category.filter-type.interface';
import { SORT_BY_CATEGORY } from './constants/category.sort-by.constant';

@Injectable()
export class CategoryService {
  constructor(
    @InjectRepository(Category)
    private readonly categoryRepository: Repository<Category>,
  ) {}

  private async checkCategoryName(name: string): Promise<void> {
    const category = await this.categoryRepository.findOne({
      where: { name: name },
    });
    if (category) {
      throw new HttpException(
        ErrorMessageCategory[401],
        ErrorCodeCategory.CATEGORY_NAME_EXISTS,
      );
    }
  }

  private async checkCategoryId(id: number): Promise<Category> {
    const category = await this.categoryRepository.findOne({
      where: { id: id },
    });
    if (!category) {
      throw new HttpException(
        ErrorMessageCategory[402],
        ErrorCodeCategory.CATEGORY_NOT_FOUND,
      );
    }
    return category;
  }

  async create(data: CreateCategoryDto): Promise<any> {
    await this.checkCategoryName(data.name);
    const category = await this.categoryRepository.create({
      name: data.name,
    });
    await this.categoryRepository.save(category);
    return await this.getOneCategoryOption(category);
  }

  async update(id: number, data: UpdateCategoryDto): Promise<any> {
    const category = await this.checkCategoryId(id);
    if (category.name != data.name) {
      await this.checkCategoryName(data.name);
    }
    category.name = data.name;
    await this.categoryRepository.save(category);
    return await this.getOneCategoryOption(category);
  }

  async getDetail(id: number): Promise<any> {
    const category = await this.checkCategoryId(id);
    return await this.getOneCategoryOption(category);
  }

  async remove(id: number): Promise<any> {
    const category = await this.checkCategoryId(id);
    await this.categoryRepository.softDelete(id);
    return {
      message: 'xoá thành công danh mục ' + category.name,
      category,
    };
  }

  async getList(filter: CategoryFilterType): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    const page: number = filter.page || 1;
    const search: string = filter.search || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'desc' ? 'DESC' : 'ASC';
    if (!SORT_BY_CATEGORY.includes(sort_by)) {
      sort_by = 'created_at';
    }

    const query = this.categoryRepository.createQueryBuilder('category');

    if (search) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('category.name LIKE :search', {
            search: `%${search}%`,
          }).orWhere('category.description LIKE :search', {
            search: `%${search}%`,
          });
        }),
      );
    }

    query.orderBy(`category.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);
    const [data, total] = await query.getManyAndCount();
    const categoryOptions = await this.getListCategoryOption(data);
    return {
      categories: categoryOptions,
      total: total,
    };
  }

  private async getOneCategoryOption(category: Category): Promise<any> {
    return {
      id: category.id,
      name: category.name,
    };
  }

  private async getListCategoryOption(categories: Category[]): Promise<any> {
    const categoryOptions = await Promise.all(
      categories.map((category) => this.getOneCategoryOption(category)),
    );

    return categoryOptions;
  }
}
