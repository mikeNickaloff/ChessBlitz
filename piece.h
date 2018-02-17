#ifndef PIECE_H
#define PIECE_H

#include <QObject>
#include <QQuickItem>
#include <QTimer>
#include <QtDebug>
#include <QDateTime>
class Piece : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(int player READ player WRITE setPlayer NOTIFY playerChanged)
    Q_PROPERTY(int rank MEMBER m_rank)
    Q_PROPERTY(QVariant imageName READ generate_image_name NOTIFY imageNameChanged)
    Q_PROPERTY(QVariant exploding READ isExploding WRITE setExploding NOTIFY explodingChanged)
    Q_PROPERTY(QVariant attackReadyTime READ attackReadyTime WRITE setAttackReadyTime NOTIFY attackReadySet)
public:
    Piece();
   /* enum playerColors {
        playerWhite,
        playerBlack
    };
    enum pieceRanks {
        rankPawn,
        rankBishop,
        rankKnight,
        rankRook,
        rankQuen,
        rankKing
    }; */
    int m_owner;
    int m_rank;
    bool m_exploding;
    int m_attackReadyTime;
    bool m_canAttack;
    Q_INVOKABLE QString generate_image_name();
    Q_INVOKABLE QVariant isExploding() { return QVariant::fromValue(m_exploding);  }
    Q_INVOKABLE QVariant attackReadyTime() { return QVariant::fromValue(m_attackReadyTime); }
    Q_INVOKABLE int player() { return m_owner; }
signals:
    void rankChanged(QString new_image);
    void imageNameChanged(QString new_name);
    void taken(QVariant new_name);
    void explodingChanged(QVariant new_val);
    void attackReadySet(QVariant new_val);
    void attackIsReady();
    void playerChanged(int new_player);
public slots:
    void update_image_name();
    void setExploding(QVariant new_val) { m_exploding = new_val.toBool(); emit this->explodingChanged(new_val); if (new_val.toBool() == true) { QTimer::singleShot(300, this, SLOT(stopExplosion())); } }
    void stopExplosion();
    Q_INVOKABLE void setAttackReadyTime(QVariant new_val) { if (m_owner < 2) {  m_attackReadyTime = new_val.toInt(); /*QTimer::singleShot(new_val.toInt() * 1000 - 500, this, SLOT(attackReady())); */ m_canAttack = false; emit this->attackReadySet(QVariant::fromValue(new_val.toInt() - QDateTime::currentSecsSinceEpoch()));  } }
    void attackReady() { emit attackIsReady(); m_canAttack = true; }
    void setPlayer(int new_player) { m_owner = new_player; emit this->playerChanged(new_player); }
};

#endif // PIECE_H