#include "piece.h"
#include "square.h"
#include <QTimer>
#include <QtDebug>
Piece::Piece()
{
m_owner = 0;
m_rank = 0;
m_canAttack = 0;
}

QString Piece::generate_image_name()
{

    QStringList colors;
    QStringList ranks;
    colors << "w" << "b";
    ranks << "p" << "b" << "n" << "r" << "q" << "k";
    return QString("images/c_%1%2.svg").arg(colors.at(this->m_owner)).arg(ranks.at(m_rank));
}

void Piece::update_image_name()
{
    if (m_owner > 1) { emit this->taken(""); } else {
    emit this->imageNameChanged(generate_image_name());
    }



}

void Piece::stopExplosion()
{
  //  qDebug() << "stopped explosion";
    this->setExploding(false);
    emit this->explodingChanged(QVariant::fromValue(false));
}
