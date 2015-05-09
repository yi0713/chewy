require 'chewy/type/adapter/orm'

module Chewy
  class Type
    module Adapter
      class ActiveRecord < Orm

        def chain_target klass, path
          path.inject(klass) do |parent_class, segment|
            break unless parent_class
            parent_class.reflect_on_association(segment).try(:klass) ||
              (parent_class.send(segment).klass if parent_class.respond_to?(segment) &&
                parent_class.send(segment).is_a?(::ActiveRecord::Relation))
          end
        end

        def columns_exists? klass, columns
          columns.all? { |column| klass.columns_hash[column.to_s] }
        end

        def columns_data klass, path, columns, ids
          path.slice_before(class: klass) do |segment, memo|
            reflection = memo[:class].reflect_on_association(segment)
            memo[:class] = reflection.klass if reflection
          end.with_object(class: klass, result: Hash[ids.zip([])]) do |segments, memo|
            reflection = memo[:class].reflect_on_association(segments.first)
            p segments
            p memo[:class]
            p reflection.macro
            p memo[:class].new.association(segments.first).association_scope.to_sql
            scope = case reflection.macro
            when :belongs_to
            when :has_one
            else
            end

            memo[:class] = reflection.klass
          end[:result]
        end

      private

        def cleanup_default_scope!
          if Chewy.logger && (@default_scope.arel.orders.present? ||
             @default_scope.arel.limit.present? || @default_scope.arel.offset.present?)
            Chewy.logger.warn('Default type scope order, limit and offest are ignored and will be nullified')
          end

          @default_scope = @default_scope.reorder(nil).limit(nil).offset(nil)
        end

        def import_scope(scope, batch_size)
          scope = scope.reorder(target_id.asc).limit(batch_size)

          ids = pluck_ids(scope)
          result = true

          while ids.any?
            result &= yield grouped_objects(default_scope_where_ids_in(ids))
            break if ids.size < batch_size
            ids = pluck_ids(scope.where(target_id.gt(ids.last)))
          end

          result
        end

        def pluck_ids(scope)
          scope.pluck(target.primary_key.to_sym)
        end

        def scope_where_ids_in(scope, ids)
          scope.where(target_id.in(Array.wrap(ids)))
        end

        def all_scope
          target.where(nil)
        end

        def target_id
          target.arel_table[target.primary_key]
        end

        def relation_class
          ::ActiveRecord::Relation
        end

        def object_class
          ::ActiveRecord::Base
        end
      end
    end
  end
end
