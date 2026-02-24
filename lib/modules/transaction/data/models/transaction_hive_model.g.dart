// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionHiveModelAdapter extends TypeAdapter<TransactionHiveModel> {
  @override
  final int typeId = 2;

  @override
  TransactionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionHiveModel(
      id: fields[0] as String,
      senderId: fields[1] as String,
      receiverId: fields[2] as String,
      referenceId: fields[3] as String,
      referenceType: fields[4] as String,
      totalAmount: fields[5] as double,
      commissionAmount: fields[6] as double,
      receiverAmount: fields[7] as double,
      status: fields[8] as String,
      createdAt: fields[9] as DateTime,
      completedAt: fields[10] as DateTime?,
      failureReason: fields[11] as String?,
      paymentGatewayTransactionId: fields[12] as String?,
      notes: fields[13] as String?,
      cachedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.receiverId)
      ..writeByte(3)
      ..write(obj.referenceId)
      ..writeByte(4)
      ..write(obj.referenceType)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.commissionAmount)
      ..writeByte(7)
      ..write(obj.receiverAmount)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.failureReason)
      ..writeByte(12)
      ..write(obj.paymentGatewayTransactionId)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
